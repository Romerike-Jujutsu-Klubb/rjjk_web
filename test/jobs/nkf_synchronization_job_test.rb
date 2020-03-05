# frozen_string_literal: true

require 'test_helper'

class NkfSynchronizationJobTest < ActionMailer::TestCase
  test 'perform' do
    users(:lars).update! email: 'lebraten@gmail.com'
    AnnualMeeting.create! start_at: '2015-02-12 17:45'
    assert_emails(3) do
      VCR.use_cassette('NKF Synchronization', match_requests_on: %i[method host path query body],
                                             allow_playback_repeats: true) do
        NkfSynchronizationJob.perform_now
      end
    end

    nkf_new_count = 412
    nkf_update_count = 3
    nkf_change_count = nkf_new_count + nkf_update_count
    import_mail = ActionMailer::Base.deliveries[0]
    import_body = import_mail.body.decoded
    assert_match(/^Hentet #{nkf_change_count} endringer fra NKF$/, import_mail.subject, import_body)
    assert_equal 'uwe@kubosch.no', import_mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', import_mail.header[:from].value
    assert_match "NKF Import\r\n\r\nEndringer fra NKF-portalen.\r\n", import_body
    assert_match(/\b#{nkf_new_count} medlemmer opprettet\r\n#{nkf_update_count} medlemmer oppdatert\r\n/,
        import_body)
    assert_match "Endringer prøvetid:\r\n", import_body
    assert_match "Nye medlemmer:\r\n\r\n    Sebastian Aagren:\r\n", import_body

    rjjk_new_count = 413
    mail = ActionMailer::Base.deliveries[1]
    assert_match(/Oppdateringer fra NKF: #{rjjk_new_count} nye/, mail.subject)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match(/Opprettet følgende nye medlemmer \(#{rjjk_new_count}\).*Abdorahman Lutf Muhammad/,
        mail.body.decoded)
    changes = <<~HTML.chomp # You can compare DOMS at http://prettydiff.com/
      <h2>Opprettet følgende nye medlemmer (413)</h2>
      <ul>
        <li>Abdorahman Lutf Muhammad</li><li>Adrian Ingebrigtsen</li><li>Adrian Skandfer Backer</li><li>Albert Atavov</li><li>Albert Ibragimovitsj Dzortov</li><li>Aleksa Kujacic</li><li>Aleksander Brustad</li><li>Aleksander Svendsen</li><li>Aleksander Woldseth</li><li>Alex Tran</li><li>Alex Tran</li><li>Amalie Wefring</li><li>Amanda Holm Endreson</li><li>An Dy Le</li><li>Anastasia Lysik</li><li>Andreas Holter</li><li>Andreas Refsum</li><li>Andreas Wagner</li><li>Andreas Buvarp Solheim</li><li>Andreas Erik Wagner</li><li>Andreas Fjeld Nymoen</li><li>Andrew Suhanthakamar</li><li>Anita Bredesen</li><li>Anita Tveter</li><li>Anne Celine Nygaard Weiseth</li><li>Annika Steffensen Coder</li><li>Anojan Christopher</li><li>Anthony Le</li><li>Arham Abbas</li><li>Arman Mehryar</li><li>Aron Bårdseng</li><li>Aryan Mathiesen</li><li>Asle Jåsund</li><li>Atle Tollefsen</li><li>Atle Romundgard Olaisen</li><li>Atthairn Phopon</li><li>Audun Skuggerud</li><li>Aurora Thomassen</li><li>Ayla Steffensen Coder</li><li>Ayoub Nehad Alayoubi</li><li>Bahram Hansen</li><li>Bastian Filip Krohn</li><li>Benedicte Skaali Madsen</li><li>Benjamin Hidas</li><li>Benjamin Lachmann</li><li>Benjamin Ullerud Westby</li><li>Bent Nymoen Evensen</li><li>Berdia Naroei</li><li>Birk Stenvik</li><li>Bjørg Tørring</li><li>Bjørnar Willassen</li><li>Casper Sveum</li><li>Cathrine Jeanette Brecht</li><li>Celine Basnes Jacobsen</li><li>Christian Muri</li><li>Christina Ciccomartini</li><li>Clark Eugene Junio Mariano</li><li>Connie Oberster</li><li>Curt Mekiassen</li><li>Dan Ha Ngyuen</li><li>Daner Diler Omer</li><li>Daniel Haraldsen</li><li>Daniel Kind</li><li>Daniel Sydhagen</li><li>Daniel Westgaard</li><li>Danny Tran</li><li>David Harasymowicz</li><li>David Harasymowicz</li><li>David Le Huynh</li><li>Dennis Christensen</li><li>Dennis Kristiansen</li><li>Dennis Brede Nielsen</li><li>Dina Diler Omer</li><li>E.V. Ingebrigt Steen</li><li>Edvard Hendbukt Norgren</li><li>Eirik Bentestuen</li><li>Eirik Stenvik</li><li>Eirik Sander Frigaard-Stern</li><li>Elias Buvik</li><li>Elias Zina</li><li>Elias Emanuel Ekbør</li><li>Elina Kerimova</li><li>Ella H. Haugen</li><li>Emil Thomassen</li><li>Emile Ihlang</li><li>Emilia Penz</li><li>Erik Le</li><li>Erik Tollefsen Brenna</li><li>Erik Øyan</li><li>Erik Øyan</li><li>Erin Andrea Dahl Bråten</li><li>Erin Andrea Dahl Bråten</li><li>Eskil Bredahl</li><li>Espen Westbye</li><li>FEIL FEIL</li><li>Fabia Buranello Johnson</li><li>Felix Fredriksen</li><li>Finn Bertrand Moen</li><li>Fredrik Dahl</li><li>Fredrik Mørk</li><li>Fredrik Dahl Bråten</li><li>Fredrik Dahl Bråten</li><li>Fredrik Høyer Forsland</li><li>Fredrik Saxer Aune</li><li>Frida Næss</li><li>Frode Harwiss</li><li>Frode Leffertstra</li><li>Fumina Taraldsen</li><li>Gabriel Storm Johansen</li><li>Gard Svele</li><li>Garm Sætre</li><li>Gausick Ratinam</li><li>Gautam Ratinam</li><li>Geetaa Ratinam</li><li>George Kian Nuñez</li><li>Gladys Njeri</li><li>Gorm Grønberg Lyngdal</li><li>Hajar Khezri</li><li>Hakan Ceylan</li><li>Halfdan Rydbeck</li><li>Hanne Haugen</li><li>Hanne Sigvartsen</li><li>Hans Jakob Grimstad</li><li>Hans Petter Skolsegg</li><li>Harald Andreas Duklæt</li><li>Harald T. Løkken</li><li>Hauk Sogstad Holter</li><li>Helena Boger</li><li>Helena Lien</li><li>Henning Jølstadengen</li><li>Henning Løvstad</li><li>Henrik Karlsen</li><li>Henrik Lien</li><li>Henrik Linløkken</li><li>Henrik Alexander Bjørhall</li><li>Henry Phung</li><li>Henry Phung</li><li>Herlof Herlofsen</li><li>Herman Kopstad Berentsen</li><li>Herman Snare</li><li>Hermine Riise Kristiansen</li><li>Håkon Myklebust Haakensen</li><li>Håvar Kristoffersen</li><li>Ibrahim Zulfiqar Butt</li><li>Ibrahim Zulfiqar Butt</li><li>Ida Kristiane Espejord</li><li>Ida Sørå Johansen</li><li>Ina Rødningsby Olsen</li><li>Ine Olaisen Romundgard</li><li>Inga Bækholt Resløkken</li><li>Inger Wold</li><li>Isabell-Ann Deposoy Teige</li><li>Isak Gahrmaker Hjermstad</li><li>Iselin Østern</li><li>Ivo Krogsæter Bollum</li><li>Jakob Bangsund</li><li>Jamie  Bjørnstad O&#39;Neill</li><li>Jan Tomas Barton</li><li>Jason Aaron Davidson</li><li>Jens-Harald Johansen</li><li>Jerry Sara Promwut</li><li>Jesper Johan Linckert</li><li>Jimmy Nguyen</li><li>Johan Klever</li><li>Johan Laake</li><li>Johannes Aspvik</li><li>Johannes Berg</li><li>Johnny Phung</li><li>Jon Petter Harwiss</li><li>Jonas Levander Alfredsen</li><li>Jonas Vågåsar</li><li>Jonas Emil Skaug</li><li>Jonas Gilleberg Toftenes</li><li>Jonathan Hagberg Nor</li><li>Jonathan Elias Holme</li><li>Jonathan Moen Holmen</li><li>Julian Van Ek Østbye</li><li>Julie Ekhøy</li><li>Julie Huynh Scharff</li><li>Juliette Ihlang</li><li>Jørgen Daland Bjørnsen</li><li>Jørgen Granum Nordahl</li><li>Jørgen stray Guttormsen</li><li>Jørn Grotnes</li><li>Karina Nygaard Øynes</li><li>Karl Kristian Indreeide</li><li>Karl Vegar Larsen</li><li>Karoline Nyhammer</li><li>Katarina Murphy</li><li>Katarzyna Krohn</li><li>Katelam Ha</li><li>Kenneth Duong</li><li>Kenneth Groth</li><li>Kenneth Kronstad</li><li>Kenneth Paulsen</li><li>Kenny Huynh</li><li>Kent André Grebstad</li><li>Kevin Duong</li><li>Kim Ronnie Sandnes</li><li>Kine Lunde</li><li>Kine Skrimstad</li><li>Knut Lauritzen</li><li>Kristian Johansen</li><li>Kristian Olaussen</li><li>Kristin Eljevåg-Grov</li><li>Kuba Pawlowski</li><li>Kurt Steinar Johansen</li><li>Kåre A. Brustad</li><li>Lakshman Senthil</li><li>Lars Erling Bråten</li><li>Leander Øyen Hejtmanek</li><li>Leif Stavseth</li><li>Leif-Arne Kristiansen</li><li>Leila Ibragimovna Dzortova</li><li>Leon Schrøder Spolén</li><li>Lilia Jemmali</li><li>Lilja Lamont</li><li>Linnea Christiansen</li><li>Linnea Amalie Bredesen Nybak</li><li>Lucas Lyhus</li><li>Ludvig Smedbråten</li><li>Lukas Berntsen</li><li>Maatii G Ebsa</li><li>Mads Gjevert Pettersen</li><li>Magne-Vegard Merkesdal</li><li>Magnus Lekvold</li><li>Magnus Sebastian Sølvesen-Myhre</li><li>Maja Kumor</li><li>Maja Soleng</li><li>Maja Tørstad Johnsrud</li><li>Marco Antonio Arias-Brunet</li><li>Marcus Berg</li><li>Marcus Aleksander Berg</li><li>Marcus Westvang Andreassen</li><li>Marie Estelle Blengsli</li><li>Marita Rudi</li><li>Marius Frang</li><li>Marius Gausel</li><li>Marius Klever</li><li>Marius Kløften</li><li>Marius Nystuen Sveen</li><li>Marius Skjervold</li><li>Marius Blesvik Dahlen</li><li>Marius Gjevert Pettersen</li><li>Markas Krasauskas</li><li>Markus Ertesvåg</li><li>Markus Hertaas</li><li>Martin Jonassen</li><li>Martin Pham Do</li><li>Martin Vågåsar</li><li>Martin Frilseth Grønvold</li><li>Martin Schilling Lier</li><li>Mathias Grødtlien</li><li>Mathias Dahl Bråten</li><li>Mathias Dahl Bråten</li><li>Mathilde Gripp</li><li>Mathilde Skrimstad</li><li>Mathushan Senthil</li><li>Matias Leunell Enger</li><li>Mats Evensen</li><li>Mats Tørstad Johnsrud</li><li>May Kristin Lyamouri Bredahl</li><li>Maya Bangsund</li><li>Medin Buvik</li><li>Michael Nepomuceno</li><li>Mikkel Lauritsen</li><li>Mina Riis</li><li>Minh Dy Le</li><li>Minh Dy Le</li><li>Momin Zulfiqar Butt</li><li>Momin Zulfiqar Butt</li><li>Morten Endreson</li><li>Morten Jacobsen</li><li>Morten Linløkken</li><li>Morten Linløkken</li><li>Muhammad Lutf Muhammad</li><li>Muhammed Gøksu</li><li>Muzamel Waziri</li><li>Nadzhi Aliev Aliev</li><li>Nanette N.M. Eriksen</li><li>Natalie Millenberg</li><li>Natalie Søgård</li><li>Nathalie Skandfer Backer</li><li>Nguyen Huynh</li><li>Nicolai Hagen</li><li>Nora Marlén Ulvær</li><li>Odin Kollstrøm</li><li>Ola Kristoffersen</li><li>Ole Arthur Maruzzo Kollien</li><li>Ole-Martin Nordahl</li><li>Oliver Hansen</li><li>Oliver Hibbard</li><li>Oliver Gahrmaker Hjermstad</li><li>Oliver Hørup Kristiansen</li><li>Omèr Hussain</li><li>Oscar Rognlid</li><li>Oskar Karl Flesland</li><li>Osman Bhatti</li><li>Osman Dincer</li><li>Patrick Torp Holt</li><li>Per Stian Vikan</li><li>Peter Malum Bergerud</li><li>Peter Malum Bergerud</li><li>Petter Gudmundsen</li><li>Phillip Helvig Eriksen</li><li>Phu Chau Nguyen</li><li>Preben Holthe</li><li>Pål Østlie</li><li>Ramiz Bhatti</li><li>Remi Schau</li><li>Roald Freudenberg</li><li>Robert Aapro</li><li>Robin Berg Fabian</li><li>Robin Pereira</li><li>Romerike Jujutsu Klubb</li><li>Ronny Aune</li><li>Rune Wang</li><li>Sander Endresen</li><li>Sara Madelen Musæus</li><li>Scott Jåfs Evensen</li><li>Sebastian Aagren</li><li>Sebastian Glemmestad</li><li>Sebastian Jahren</li><li>Sebastian Mäntylä</li><li>Sebastian Tveter</li><li>Sedsel Fretheim Thomassen</li><li>Shad Rawand</li><li>Shruti Jhanjee</li><li>Sigrid Nyhammer</li><li>Sigurd Slinning Klausen</li><li>Sigve Paulsen</li><li>Silje Grov</li><li>Simen Schaufel</li><li>Simen Vågåsar</li><li>Siv Margrete Seljeflot</li><li>Sivert Jarmund</li><li>Solveig Irene Sletta</li><li>Sondre Paulsen</li><li>Steffen Sandstad</li><li>Stian Hegge-Jensen</li><li>Stian Nyblom</li><li>Stian Nyblom</li><li>Svein Michael Hauger-Rolijordet</li><li>Svein Robert Rolijordet</li><li>Tam Le</li><li>Tamara Kujacic</li><li>Tarjei Grønås</li><li>Terje Eriksen</li><li>Test Testesen</li><li>Test2 Testesen</li><li>Test3 Testesen</li><li>Thale Strøm</li><li>Thea Buvik</li><li>Thea Wethe Jahrn</li><li>Theo Jørgensen-Dahl</li><li>Theodor A Holme</li><li>Thomas Gulbrandsen</li><li>Thomas Hauger-Rolijordet</li><li>Thomas Iversen</li><li>Thomas Ødegård</li><li>Thomas Nordlie Lein</li><li>Thor André Hammer Olsen</li><li>Tim Holmen</li><li>Toan Khanh Truong</li><li>Tobias Ramsvik</li><li>Tobias Andrè Berg</li><li>Tobias Johan Aune</li><li>Tom Gulbrandsen</li><li>Tom Halvorsen</li><li>Tom Arild Knapkøien</li><li>Tom Erik Strøm</li><li>Tomas Lindgaard</li><li>Tomas Nyblom</li><li>Tomas Tangen</li><li>Tommy Lohne</li><li>Tommy Musæus</li><li>Tone Holm</li><li>Torben Græsdal</li><li>Torbjørn Sjåberg</li><li>Torbjørn Kamer Smits</li><li>Tore Skålshegg</li><li>Tran Ba Luan</li><li>Trine Eggen Bodeng</li><li>Trine Schilling Lier</li><li>Tristan Troy Rasay</li><li>Trygve Sigvartsen</li><li>Trygve Bækholt Resløkken</li><li>Tuan Anh Le</li><li>Ukko Laitinen</li><li>Ulf Ekhøy</li><li>Una Benedicte Henriksen</li><li>Vebjørn Knutsen</li><li>Vegar Norman</li><li>Vegard Dahlen</li><li>Vegard Østnes</li><li>Vetle Tenold Frisk</li><li>Victor Aas Karlstad</li><li>Victor Noah Krohn</li><li>Victoria Amber Engen</li><li>Viet Huynh</li><li>Viktor Golke</li><li>Yahya Zulfiqar Butt</li><li>Yvonne Helen Rasch</li><li>Zanetta W. Soleng</li><li>Zdenek Barton</li><li>Zurab Kerimov</li><li>fehzan ali</li><li>kevin le</li><li>kevin le</li><li>lilly sara promwut</li><li>lisa sara promwut</li><li>vegard olsson</li><li>Øivind Paulshus</li>
      </ul>
      <h2>Ville ha oppdatert følgende medlemmer hos NKF (3)</h2>
      <ul>
        <li>Lars Bråten
          <ul>
            <li>{:user=&gt;:first_name}: &quot;Lars Erling&quot; => &quot;Lars&quot;</li>
            <li>{:user=&gt;:address}: &quot;Torsvei 8B&quot; => &quot;Torsvei 8b&quot;</li>
            <li>{:user=&gt;:birthdate}: &quot;24.03.1968&quot; => &quot;21.06.1967&quot;</li>
            <li>{:membership=&gt;:phone_home}: &quot;67919906&quot; => &quot;&quot;</li>
            <li>{:membership=&gt;:phone_work}: &quot;63807253&quot; => &quot;&quot;</li>
            <li>{:user=&gt;:phone}: &quot;91735210&quot; => &quot;&quot;</li>
            <li>{:membership=&gt;:category}: "Passiv sats" =&gt; "Voksen"</li>
            <li>{:membership=&gt;:contract}: "Passiv - Voksen" =&gt; "Voksen"</li>
            <li>{:membership=&gt;:discount}: "" =&gt; "100"</li>
            <li>{:membership=&gt;:joined_on}: &quot;14.10.2003&quot; => &quot;21.06.2007&quot;</li>
          </ul>
        </li>
        <li>Sebastian Kubosch<ul>
            <li>{:user=&gt;:contact_email}: &quot;sebastian@kubosch.no&quot; => &quot;sebastian@example.com&quot;</li>
            <li>{:billing=&gt;:email}: &quot;lise@kubosch.no&quot; => &quot;&quot;</li>
            <li>{:membership=&gt;:category}: "Passiv sats" =&gt; "Barn"</li>
            <li>{:membership=&gt;:contract}: "Passiv - Ungdom" =&gt; "Barn - familie"</li>
            <li>{:membership=&gt;:discount}: "" =&gt; "100"</li>
            <li>{:membership=&gt;:joined_on}: &quot;21.09.2010&quot; => &quot;25.08.2007&quot;</li>
            <li>{:guardian_1=&gt;:email}: &quot;lise@kubosch.no&quot; => &quot;lise@example.com&quot;</li>
            <li>{:guardian_1=&gt;:phone}: &quot;&quot; => &quot;98765432&quot;</li>
            <li>{:guardian_2=&gt;:phone}: &quot;92206046&quot; => &quot;5556666&quot;</li>
          </ul>
        </li>
        <li>Uwe Kubosch<ul>
            <li>{:user=&gt;:phone}: &quot;92206046&quot; => &quot;5556666&quot;</li>
            <li>{:user=&gt;:contact_email}: &quot;uwe@kubosch.no&quot; => &quot;uwe@example.com&quot;</li>
            <li>{:membership=&gt;:category}: "Voksne sats" =&gt; "Voksen"</li>
            <li>{:membership=&gt;:contract}: "Instruktør V2" =&gt; "Voksen"</li>
            <li>{:membership=&gt;:discount}: "" =&gt; "100"</li>
            <li>{:membership=&gt;:joined_on}: &quot;15.12.2000&quot; => &quot;05.01.1987&quot;</li>
          </ul>
        </li>
      </ul>
    HTML
    expected_doc = Nokogiri::HTML(changes, &:noblanks)
    actual_doc = Nokogiri::HTML(mail.body.decoded, &:noblanks)

    expected_doc.xpath('//text()').each do |node|
      /\S/.match?(node.content) ? node.content = node.content.strip : node.remove
    end
    actual_doc.xpath('//text()').each do |node|
      /\S/.match?(node.content) ? node.content = node.content.strip : node.remove
    end

    diff = +''
    expected_doc.diff(actual_doc) do |change, node|
      next if change == ' '

      diff << "#{change} #{node.to_html}".ljust(30) + ' ' + node.parent.path + "\n"
    end
    assert_empty diff, "\n#{diff}"

    # assert_dom_equal(changes, body)
    mail = ActionMailer::Base.deliveries[2]
    assert_equal 'Verv fra NKF: 9', mail.subject
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match '<h3>Verv registrert i NKF registeret</h3>', mail.body.decoded
    assert_match %r{
          <td>Uwe\ Kubosch</td>\s*
          <td>Hovedinstruktør</td>\s*
          <td>2013-01-01</td>\s*
          <td></td>
        }x,
        mail.body.decoded
    assert_match %r{
          <td>Svein\ Robert\ Rolijordet</td>\s*
          <td>Leder\ \(2\ år\)</td>\s*
          <td>2014-02-25</td>\s*
          <td>2015-02-12</td>
        }x,
        mail.body.decoded
    assert_match %r{
          <td>Bastian\ Filip\ Krohn</td>\s*
          <td>Kasserer\ \(2\ år\)</td>\s*
          <td>2015-02-12</td>\s*
          <td></td>
        }x,
        mail.body.decoded
  end
end
