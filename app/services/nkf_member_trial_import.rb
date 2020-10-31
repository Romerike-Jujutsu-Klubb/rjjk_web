# frozen_string_literal: true

class NkfMemberTrialImport
  include ParallelRunner
  include MonitorMixin

  attr_reader :error_records, :exception, :trial_changes

  # @param nkf_member_ids [Integer|Array<Integer>] only import the given NKF member id(s)
  def initialize(nkf_agent = nil)
    super() # needed for MonitorMixin
    @trial_changes = []
    @error_records = []
    @cookies = []

    unless nkf_agent
      nkf_agent = NkfAgent.new(:trial_import)
      nkf_agent.login
    end
    import_member_trials(get_member_trial_rows(nkf_agent))
  rescue => e
    @exception = e
  end

  def size
    trial_changes&.size.to_i + error_records&.size.to_i
  end

  def any?
    @exception || size.positive?
  end

  private

  def get_member_trial_rows(nkf_agent)
    logger.debug 'get_member_trial_rows'
    trial_csv_url =
        "pls/portal/myports.ks_godkjenn_medlem_proc.exceleksport?p_cr_par=#{nkf_agent.session_id}"
    member_trials_csv_body = nkf_agent.get(trial_csv_url).body
        .force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8)
    member_trial_rows = member_trials_csv_body.split("\n").map { |line| line.chomp.split(';') }

    trial_ids = []
    extra_function_code = nkf_agent.extra_function_codes[0][0]
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
    member_trial_rows[0] << 'kjonn'

    trial_ids.each do |tid|
      trial_details_url = 'page/portal/ks_utv/vedl_portlets/ks_godkjenn_medlem' \
          "?p_ks_godkjenn_medlem_action=UPDATE&frm_28_v04=#{tid}&p_cr_par=" +
          extra_function_code
      trial_details_body = nkf_agent.get(trial_details_url).body
          .force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8)

      raise 'Could not find first_name' unless trial_details_body =~ /name="frm_28_v08" value="(.*?)"/

      first_name = Regexp.last_match(1)

      unless trial_details_body =~ /name="frm_28_v09" value="(.*?)"/
        logger.error trial_details_body
        raise 'Could not find last name'
      end
      last_name = Regexp.last_match(1)

      raise 'Could not find invoice_email' unless trial_details_body =~ /name="frm_28_v25" value="(.*?)"/

      invoice_email = Regexp.last_match(1)

      unless trial_details_body =~ %r{<select class="inputTextFull" name="frm_28_v28" id="frm_28_v28"><option value="-1">- Velg gren/stilart -</option>.*?<option selected value="\d+">([^<]*)</option>.*</select>} # rubocop: disable Layout/LineLength
        raise 'Could not find martial art'
      end

      martial_art = Regexp.last_match(1)

      unless trial_details_body =~ /<select [^>]* id="frm_28_v15"[^>]*>.*?<option value="([MKI])" selected>/m # rubocop: disable Layout/LineLength
        raise "Could not find sex:\n#{trial_details_body}"
      end

      sex = Regexp.last_match(1)

      trial_row = member_trial_rows.find do |ir|
        ir.size < member_trial_rows[0].size && ir[1] == last_name && ir[2] == first_name
      end
      if trial_row
        trial_row << tid
        trial_row << invoice_email.presence
        trial_row << martial_art
        trial_row << sex
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

  def import_member_trials(member_trial_rows)
    header_fields = member_trial_rows.shift
    columns = header_fields.map { |f| field2column(f) }
    logger.debug "Found #{member_trial_rows.size} member trials"
    logger.debug "Columns: #{columns.inspect}"
    tid_col_idx = header_fields.index 'tid'
    orphaned_trials =
        NkfMemberTrial.where.not(tid: member_trial_rows.map { |t| t[tid_col_idx] }).to_a
    orphaned_trials.each(&:destroy!)
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
      # record ||= NkfMemberTrial.find_by(reg_dato: row[columns.index('reg_dato')],
      #     fornavn: row[columns.index('fornavn')],
      #     etternavn: row[columns.index('etternavn')])
      record ||= NkfMemberTrial.new
      record.attributes = attributes
      next unless record.changed? || record.signup.nil?

      c = record.changes
      if record.save
        @trial_changes << { record: record, changes: c }
        if record.signup.nil?
          user = User.find_by(email: record.epost) if record.epost.present?
          user ||= User.find_by(phone: record.mobil) if record.mobil.present?
          user ||= User.create!(record.user_attributes)
          Signup.create! user: user, nkf_member_trial: record
        end
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
