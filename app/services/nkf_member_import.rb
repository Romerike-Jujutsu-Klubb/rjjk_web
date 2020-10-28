# frozen_string_literal: true

class NkfMemberImport
  include ParallelRunner
  include MonitorMixin

  attr_reader :changes, :error_records, :exception, :import_rows, :new_records, :nkf_agent

  # @param nkf_member_ids [Integer|Array<Integer>] only import the given NKF member id(s)
  def initialize(nkf_member_ids = nil)
    super() # needed for MonitorMixin
    if nkf_member_ids
      nkf_member_ids = Array(nkf_member_ids)
      nkf_member_id = nkf_member_ids[0] if nkf_member_ids.size == 1
    end
    @new_records = []
    @changes = []
    @error_records = []
    @cookies = []

    @nkf_agent = NkfAgent.new(:import)
    @nkf_agent.login

    search_body = @nkf_agent.search_members(nkf_member_id)

    @import_rows = get_member_rows(@nkf_agent)
    detail_codes = search_body.scan(/edit_click27\('(.*?)'\)/).map { |dc| dc[0] }
    if nkf_member_ids
      @import_rows.select! do |row|
        nkf_member_ids.include?(row[0].to_i) || row[0] == 'Medlemsnummer'
      end
    end
    add_details(@nkf_agent, @import_rows, detail_codes)
    import_member_rows(@import_rows)
  rescue => e
    @exception = e
  end

  def size
    new_records.try(:size).to_i + changes.try(:size).to_i + error_records.try(:size).to_i
  end

  def any?
    @exception || size.positive?
  end

  private

  def get_member_rows(nkf_agent)
    members_body = nkf_agent
        .get("pls/portal/myports.ks_reg_medladm_proc.download?p_cr_par=#{nkf_agent.session_id}")
        .body
        .force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8)
    import_rows = members_body.split("\n")
        .map { |line| CGI.unescapeHTML(line.chomp).gsub(/[^[:print:]]/, '').split(';', -1)[0..-2] }
    sort_groups(import_rows)
    import_rows
  end

  def sort_groups(import_rows)
    groups_index = import_rows[0].index { |f| f =~ %r{^Gren/Stilart/Avd/Parti} }
    raise 'Column not found' unless groups_index

    import_rows[1..].each do |row|
      groups_names = row[groups_index].split(' - ')
      groups_names.each do |gn|
        unless /^(Jujutsu|Aikido)/.match?(gn)
          raise "Bad martial arts name: #{gn.inspect} (#{row[groups_index].inspect})"
        end
      end
      row[groups_index] = groups_names.sort.join(' - ')
    end
  end

  def add_details(nkf_agent, import_rows, detail_codes)
    import_rows[0] << 'ventekid'
    import_rows[0] << 'hoyde'
    awk_start = Time.current
    in_parallel(detail_codes) do |dc, queue|
      logger.debug "add member ventekid: #{queue.size}" if queue.size % 50 == 0
      add_row_details(nkf_agent, import_rows, dc)
    end
    logger.debug "add member ventekid...ok...#{Time.current - awk_start}s"
  end

  def add_row_details(nkf_agent, import_rows, dc)
    details_page = nkf_agent.get("page/portal/ks_utv/ks_medlprofil?p_cr_par=#{dc}")
    details_body = details_page.body
    unless details_body =~ /class="inputTextFullRO" id="frm_48_v02" name="frm_48_v02" value="(\d+?)"/
      raise "Could not find member id:\n#{details_page.code}\n#{details_body.inspect}"
    end

    member_id = Regexp.last_match(1)

    unless (import_row_for_member_id = import_rows.find { |ir| ir[0] == member_id })
      raise "Missing import_row for member_id: #{member_id.inspect}\n#{import_rows.pretty_inspect}"
    end

    active = details_body.include?('<input type="text" class="displayTextFull" value="Aktiv ">')
    if details_body =~ %r{<span class="kid_1">(\d+)</span><span class="kid_2">(\d+)</span>}
      waiting_kid = "#{Regexp.last_match(1)}#{Regexp.last_match(2)}"
    end
    raise 'Both Active status and waiting kid were found' if active && waiting_kid
    raise "Neither active status nor waiting kid were found:\n#{details_body}" if !active && !waiting_kid

    import_row_for_member_id << waiting_kid

    details_page.form('ks_medlprofil') do |form|
      height = form[NkfMember::FIELD_MAP[:hoyde][:form_field][:member].to_s]
      import_row_for_member_id << height
    end
  end

  def import_member_rows(import_rows)
    unless import_rows && import_rows[0] &&
          import_rows[0][0] == 'Medlemsnummer'
      raise "Unknown format: #{import_rows && import_rows[0] &&
          import_rows[0][0]}"
    end
    header_fields = import_rows.shift
    columns = header_fields.map { |f| field2column(f) }
    logger.debug "Found #{import_rows.size} active members"
    import_rows.each do |row|
      logger.debug row
      attributes = {}
      columns.each_with_index do |column, i|
        next if %w[aktivitetsomrade_id aktivitetsomrade_navn alder avtalegiro
                   beltefarge dan_graderingsserifikat forbundskontingent].include? column

        attributes[column] = row[i]&.strip
      end
      record = NkfMember.find_by(medlemsnummer: row[0]) || NkfMember.new
      if record.member_id.nil?
        matching_users = User
            .where('UPPER(first_name) = ? AND UPPER(last_name) = ?',
                attributes['fornavn'].upcase, attributes['etternavn'].upcase)
            .to_a
        member = matching_users.map(&:member).compact.find { |m| m.nkf_member.nil? }
        attributes['member_id'] = member.id if member
      end
      begin
        record.attributes = attributes
      rescue ActiveRecord::UnknownAttributeError
        logger.error attributes.inspect
        raise
      end
      was_new_record = record.new_record?
      next unless record.changed?

      c = record.changes
      logger.debug "Found changes: #{c.inspect}"
      if record.save
        logger.debug "Saved changes: #{c.inspect}"
        (was_new_record ? @new_records : @changes) << { record: record, changes: c }
      else
        logger.error "ERROR: #{record.errors.to_a.join(', ')}"
        @error_records << record
      end
    end
  end

  def field2column(field_name)
    field_name.tr('ø', 'o').tr('Ø', 'O').tr('å', 'a').tr('Å', 'A').gsub(%r{[ -./]}, '_').downcase
  end
end
