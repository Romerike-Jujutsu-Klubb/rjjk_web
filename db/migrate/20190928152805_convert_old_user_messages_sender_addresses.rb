# frozen_string_literal: true

class ConvertOldUserMessagesSenderAddresses < ActiveRecord::Migration[5.2]
  Mail::Parsers::AddressStruct = Mail::Parsers::AddressListsParser::AddressStruct
  Mail::Parsers::AddressListStruct = Mail::Parsers::AddressListsParser::AddressListStruct
  def change
    UserMessage.order(:created_at).each { |um| um.update! from: um.from.to_a }
  end
end
