# frozen_string_literal: true

class NkfMemberImport
  include ParallelRunner
  include MonitorMixin

  attr_reader :changes, :error_records, :exception, :import_rows, :new_records, :trial_changes

  # TODO(uwe): Move these methods to a separate Job class
  def self.import_nkf_changes
    begin
      logger.info 'Import memberships from NKF'
      i = NkfMemberImport.new
      if i.any?
        NkfReplicationMailer.import_changes(i).deliver_now
        logger.info 'Sent NKF member import mail.'
        logger.info 'Oppdaterer kontrakter'
        NkfMember.update_group_prices
      end
    rescue => e
      handle_exception('Execption sending NKF import email.', e)
    end

    begin
      ActiveRecord::Base.transaction do
        c = NkfMemberComparison.new
        c.sync
        if c.any?
          NkfReplicationMailer.update_members(c).deliver_now
          logger.info 'Sent update_members mail.'
        end
      end
    rescue => e
      handle_exception('Execption sending update_members email.', e)
    end

    begin
      a = NkfAppointmentsScraper.import_appointments
      NkfReplicationMailer.update_appointments(a).deliver_now if a.any?
    rescue => e
      handle_exception('Execption sending update_appointments email.', e)
    end
  end

  def self.handle_exception(context, e)
    logger.error context
    logger.error "#{e.class} #{e.message}"
    logger.error e.backtrace.join("\n")
    ExceptionNotifier.notify_exception(e)
    raise if Rails.env.test?
  end
  # ODOT

  def size
    new_records.try(:size).to_i + changes.try(:size).to_i + error_records.try(:size).to_i
  end

  def any?
    @exception || size.positive?
  end

  def initialize(nkf_member_id = nil)
    super
    @new_records = []
    @changes = []
    @trial_changes = []
    @error_records = []
    @cookies = []

    nkf_agent = NkfAgent.new
    nkf_agent.login # returns front_page

    # TODO(uwe): Change to use Mechanize primitives like `click` and scan using nokogiri (css/xpath)
    search_body = nkf_agent.search_members(nkf_member_id)

    session_id = search_body.scan(/Download27\('(.*?)'\)/)[0][0]
    raise 'Could not find session id' unless session_id

    detail_codes = search_body.scan(/edit_click27\('(.*?)'\)/).map { |dc| dc[0] }
    @import_rows = get_member_rows(nkf_agent, session_id, detail_codes)

    extra_function_codes = search_body.scan(/start_tilleggsfunk27\('(.*?)'\)/)
    raise search_body if extra_function_codes.empty?
    extra_function_code = extra_function_codes[0][0]
    member_trial_rows = get_member_trial_rows(nkf_agent, session_id, extra_function_code)

    import_member_rows(@import_rows)
    import_member_trials(member_trial_rows)
  rescue => e
    @exception = e
  end

  private

  def get_member_rows(nkf_agent, session_id, detail_codes)
    members_body = nkf_agent
        .get("pls/portal/myports.ks_reg_medladm_proc.download?p_cr_par=#{session_id}")
        .body
        .force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8)
    import_rows = members_body.split("\n")
        .map { |line| CGI.unescapeHTML(line.chomp).gsub(/[^[:print:]]/, '').split(';', -1)[0..-2] }
    add_waiting_kids(nkf_agent, import_rows, detail_codes)
    import_rows
  end

  def add_waiting_kids(nkf_agent, import_rows, detail_codes)
    import_rows[0] << 'ventekid'
    logger.debug 'add member ventekid'
    awk_start = Time.current
    in_parallel(detail_codes) { |dc| add_waiting_kid(nkf_agent, import_rows, dc) }
    logger.debug "add member ventekid...ok...#{Time.current - awk_start}s"
  end

  def add_waiting_kid(nkf_agent, import_rows, dc)
    logger.debug 'add_waiting_kid'
    details_body = nil
    3.times do
      details_body = nkf_agent.get("page/portal/ks_utv/ks_medlprofil?p_cr_par=#{dc}").body
      break if details_body.present?
      logger.error 'Empty response when getting waiting KID'
    end
    logger.debug 'add_waiting_kid: got details body'
    unless details_body =~
          /class="inputTextFullRO" id="frm_48_v02" name="frm_48_v02" value="(\d+?)"/
      raise "Could not find member id:\n#{details_body.inspect}"
    end
    member_id = Regexp.last_match(1)
    active =
        if details_body =~ /<input type="text" class="displayTextFull" value="Aktiv ">/
          true
        else
          false
        end
    waiting_kid =
        if details_body =~ %r{<span class="kid_1">(\d+)</span><span class="kid_2">(\d+)</span>}
          "#{Regexp.last_match(1)}#{Regexp.last_match(2)}"
        end
    raise 'Both Active status and waiting kid were found' if active && waiting_kid
    raise "Neither active status nor waiting kid were found:\n#{details_body}" if !active && !waiting_kid
    import_rows.find { |ir| ir[0] == member_id } << waiting_kid
  end

  def get_member_trial_rows(nkf_agent, session_id, extra_function_code)
    logger.debug 'get_member_trial_rows'
    trial_csv_url = 'pls/portal/myports.ks_godkjenn_medlem_proc.exceleksport?p_cr_par=' + session_id
    member_trials_csv_body = nkf_agent.get(trial_csv_url).body
        .force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8)
    member_trial_rows = member_trials_csv_body.split("\n").map { |line| line.chomp.split(';') }

    trial_ids = []
    (member_trial_rows.size.to_f / 20).ceil.times do |page|
      trial_url = 'page/portal/ks_utv/vedl_portlets/ks_godkjenn_medlem?' \
          "p_page_search=#{page + 1}&p_cr_par=#{extra_function_code}"
      member_trials_body = nkf_agent.get(trial_url).body
      new_trial_ids = member_trials_body.scan(/edit_click28\('(.*?)'\)/).map { |tid| tid[0] }
      trial_ids += new_trial_ids
    end

    member_trial_rows[0] << 'tid'
    member_trial_rows[0] << 'epost_faktura'
    member_trial_rows[0] << 'stilart'

    trial_ids.each do |tid|
      trial_details_url = 'page/portal/ks_utv/vedl_portlets/ks_godkjenn_medlem' \
          "?p_ks_godkjenn_medlem_action=UPDATE&frm_28_v04=#{tid}&p_cr_par=" +
          extra_function_code
      trial_details_body = nkf_agent.get(trial_details_url).body
          .force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8)
      raise 'Could not find invoice email' unless trial_details_body =~ /name="frm_28_v08" value="(.*?)"/
      first_name = Regexp.last_match(1)
      unless trial_details_body =~ /name="frm_28_v09" value="(.*?)"/
        logger.error trial_details_body
        raise 'Could not find last name'
      end
      last_name = Regexp.last_match(1)
      raise 'Could not find first name' unless trial_details_body =~ /name="frm_28_v25" value="(.*?)"/
      invoice_email = Regexp.last_match(1)
      unless trial_details_body =~ %r{<select class="inputTextFull" name="frm_28_v28" id="frm_28_v28"><option value="-1">- Velg gren/stilart -</option>.*?<option selected value="\d+">([^<]*)</option>.*</select>} # rubocop: disable Metrics/LineLength
        raise 'Could not find martial art'
      end
      martial_art = Regexp.last_match(1)
      trial_row = member_trial_rows.find do |ir|
        ir.size < member_trial_rows[0].size && ir[1] == last_name && ir[2] == first_name
      end
      if trial_row
        trial_row << tid
        trial_row << invoice_email.presence
        trial_row << martial_art
      else
        logger.error '*' * 80
        logger.error "Fant ikke prøvetidsmedlem:  #{tid.inspect}"
        logger.error "First name: #{first_name.inspect}"
        logger.error "Last name: #{last_name.inspect}"
        logger.error "invoice_email: #{invoice_email.inspect}"
        logger.error "martial_art: #{martial_art.inspect}"
        logger.error trial_details_body
        logger.error member_trial_rows
        logger.error '=' * 80
      end
    end
    member_trial_rows
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
                   beltefarge dan_graderingsserifikat forbundskontingent]
              .include? column
        attributes[column] = row[i]&.strip
      end
      record = NkfMember.find_by(medlemsnummer: row[0]) || NkfMember.new
      if record.member_id.nil?
        member = User
            .where('UPPER(first_name) = ? AND UPPER(last_name) = ?',
                UnicodeUtils.upcase(attributes['fornavn']),
                UnicodeUtils.upcase(attributes['etternavn']))
            .to_a.map(&:member).find { |m| m.nkf_member.nil? }
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
        logger.debug "Found changes: #{c.inspect}"
        (was_new_record ? @new_records : @changes) << { record: record, changes: c }
      else
        logger.error "ERROR: #{record.errors.to_a.join(', ')}"
        @error_records << record
      end
    end
  end

  def import_member_trials(member_trial_rows)
    header_fields = member_trial_rows.shift
    columns = header_fields.map { |f| field2column(f) }
    logger.debug "Found #{member_trial_rows.size} member trials"
    logger.debug "Columns: #{columns.inspect}"
    tid_col_idx = header_fields.index 'tid'
    # email_col_idx  = header_fields.index 'epost'
    missing_trials = NkfMemberTrial
        .where('tid NOT IN (?)', member_trial_rows.map { |t| t[tid_col_idx] }).to_a
    missing_trials.each do |t|
      m = User.find_by(email: t.epost)&.member
      t.trial_attendances.each do |ta|
        if m
          attrs = ta.attributes
          attrs.delete_if { |k, _| %w[id created_at updated_at].include? k }
          attrs['member_id'] = m.id
          attrs.delete('nkf_member_trial_id')
          m.attendances << Attendance.new(attrs)
        end
        ta.destroy
      end
      t.destroy
    end
    member_trial_rows.each do |row|
      attributes = {}
      columns.each_with_index do |column, i|
        column = 'medlems_type' if column == 'type'
        if row[i] =~ /^(\d\d)\.(\d\d)\.(\d{4})$/
          row[i] = "#{Regexp.last_match(3)}-#{Regexp.last_match(2)}-#{Regexp.last_match(1)}"
        elsif column == 'res_sms'
          row[i] =
              case row[i]
              when 'J'
                true
              when 'N'
                false
              else
                raise "Unknown boolean value for res_sms: #{row[i].inspect}"
              end
        end
        attributes[column] = row[i]
      end
      record = NkfMemberTrial.find_by(tid: row[columns.index('tid')])
      record ||= NkfMemberTrial.find_by(reg_dato: row[columns.index('reg_dato')],
                                        fornavn: row[columns.index('fornavn')],
                                        etternavn: row[columns.index('etternavn')])
      record ||= NkfMemberTrial.new
      record.attributes = attributes
      next unless record.changed?
      c = record.changes
      if record.save
        @trial_changes << { record: record, changes: c }
      else
        logger.error "ERROR: #{columns}"
        logger.error "ERROR: #{row}"
        logger.error "ERROR: #{record.attributes}"
        logger.error "ERROR: #{record.errors.to_a.join(', ')}"
        @error_records << record
      end
    end
  end

  def field2column(field_name)
    field_name.tr('ø', 'o').tr('Ø', 'O').tr('å', 'a').tr('Å', 'A').gsub(%r{[ -./]}, '_').downcase
  end
end
