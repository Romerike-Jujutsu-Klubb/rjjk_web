module GraduationsHelper
  def yes_no_select(cid, sid, graduate_id)
    rstr = String.new()
    nsel = !sid ? "SELECTED" : ""
    ysel = sid ? "SELECTED" : ""
    rstr << "\n<SELECT NAME='#{cid}_row_#{graduate_id}' STYLE='width: 56px; height: 18px;' ID='#{cid}_row_#{graduate_id}'>\n"
    rstr << "<OPTION #{nsel} VALUE='0'>Nei</OPTION>\n"
    rstr << "<OPTION #{ysel} VALUE='1'>Ja</OPTION>\n"
    rstr << "</SELECT>\n"
    rstr.html_safe
  end

end
