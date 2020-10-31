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

    nkf_new_count = 461
    nkf_update_count = 3
    trial_changes = 5
    nkf_change_count = nkf_new_count + nkf_update_count + trial_changes
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

    rjjk_new_count = 455
    mail = ActionMailer::Base.deliveries[1]
    assert_match(/Oppdateringer fra NKF: #{rjjk_new_count} nye, 7 feil/, mail.subject)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match(/Opprettet følgende nye medlemmer \(#{rjjk_new_count}\).*Abdorahman Lutf Muhammad/,
        mail.body.decoded)
    changes = <<~HTML.chomp # You can compare DOMS at http://prettydiff.com/
      <h2>Opprettet følgende nye medlemmer (#{rjjk_new_count})</h2>
      <ul><li>Abdorahman Lutf Muhammad</li><li>Adrian Ingebrigtsen</li><li>Adrian Skandfer Backer</li><li>Albert Atavov</li><li>Albert Ibragimovitsj Dzortov</li><li>Aleksa Kujacic</li><li>Aleksander Brustad</li><li>Aleksander Svendsen</li><li>Aleksander Woldseth</li><li>Alex Tran</li><li>Alex Tran</li><li>Ali Asjid</li><li>Amalie Wefring</li><li>Amanda Holm Endreson</li><li>An Dy Le</li><li>Anastasia Lysik</li><li>Andreas Holter</li><li>Andreas Refsum</li><li>Andreas Wagner</li><li>Andreas Buvarp Solheim</li><li>Andreas Erik Wagner</li><li>Andreas Fjeld Nymoen</li><li>Andrew Suhanthakamar</li><li>Anita Bredesen</li><li>Anita Tveter</li><li>Anja Sørensen</li><li>Anne Celine Nygaard Weiseth</li><li>Annika Steffensen Coder</li><li>Anojan Christopher</li><li>Anthony Le</li><li>Anton Emio Ballo Walter</li><li>Arham Abbas</li><li>Arman Mehryar</li><li>Aron Bårdseng</li><li>Aryan Mathiesen</li><li>Asle Jåsund</li><li>Atle Tollefsen</li><li>Atle Romundgard Olaisen</li><li>Atthairn Phopon</li><li>Audun Skuggerud</li><li>Aurora Thomassen</li><li>Axel Corneliussen</li><li>Axel Corneliussen</li><li>Ayla Steffensen Coder</li><li>Ayoub Nehad Alayoubi</li><li>Bahram Hansen</li><li>Bastian Filip Krohn</li><li>Benedicte Skaali Madsen</li><li>Benjamin Hidas</li><li>Benjamin Lachmann</li><li>Benjamin Ullerud Westby</li><li>Bent Nymoen Evensen</li><li>Berdia Naroei</li><li>Birk Stenvik</li><li>Bjørg Tørring</li><li>Bjørnar Willassen</li><li>Carl Ambrosius Blomsø</li><li>Casper Sveum</li><li>Cathrine Jeanette Brecht</li><li>Cazandra Gresnes Enger</li><li>Celine Basnes Jacobsen</li><li>Christian Muri</li><li>Christina Ciccomartini</li><li>Clark Eugene Junio Mariano</li><li>Connie Oberster</li><li>Curt Mekiassen</li><li>Dan Ha Ngyuen</li><li>Daner Diler Omer</li><li>Daniel Haraldsen</li><li>Daniel Kind</li><li>Daniel Sydhagen</li><li>Daniel Westgaard</li><li>Danny Tran</li><li>David Harasymowicz</li><li>David Harasymowicz</li><li>David Le Huynh</li><li>Dennis Christensen</li><li>Dennis Kristiansen</li><li>Dennis Møllerstuen</li><li>Dennis Brede Nielsen</li><li>Dina Diler Omer</li><li>E.V. Ingebrigt Steen</li><li>Edvard Hendbukt Norgren</li><li>Eirik Bentestuen</li><li>Eirik Stenvik</li><li>Eirik Sander Frigaard-Stern</li><li>Elias Buvik</li><li>Elias Zina</li><li>Elias Emanuel Ekbør</li><li>Elina Kerimova</li><li>Ella H. Haugen</li><li>Ellen Skjold Kvåle</li><li>Emil Thomassen</li><li>Emile Ihlang</li><li>Emilia Penz</li><li>Erik Le</li><li>Erik Tollefsen Brenna</li><li>Erik Øyan</li><li>Erik Øyan</li><li>Erin Andrea Dahl Bråten</li><li>Erin Andrea Dahl Bråten</li><li>Esben Toftenes</li><li>Eskil Bredahl</li><li>Espen Westbye</li><li>FEIL FEIL</li><li>Fabia Buranello Johnson</li><li>Felix Fredriksen</li><li>Felix Nguyen</li><li>Finn Bertrand Moen</li><li>Fredrik Dahl</li><li>Fredrik Mørk</li><li>Fredrik Dahl Bråten</li><li>Fredrik Dahl Bråten</li><li>Fredrik Høyer Forsland</li><li>Fredrik Saxer Aune</li><li>Frida Næss</li><li>Frode Harwiss</li><li>Frode Leffertstra</li><li>Fumina Taraldsen</li><li>Gabriel Storm Johansen</li><li>Gard Svele</li><li>Garm Sætre</li><li>Gausick Ratinam</li><li>Gautam Ratinam</li><li>Geetaa Ratinam</li><li>Geirr Delphin Cranner</li><li>George Kian Nuñez</li><li>Ghislain Fournous</li><li>Ghislain Fournous</li><li>Gladys Njeri</li><li>Gorm Grønberg Lyngdal</li><li>Hajar Khezri</li><li>Hakan Ceylan</li><li>Halfdan Rydbeck</li><li>Hanne Haugen</li><li>Hanne Sigvartsen</li><li>Hans Jakob Grimstad</li><li>Hans Petter Skolsegg</li><li>Harald Andreas Duklæt</li><li>Harald T. Løkken</li><li>Hauk Sogstad Holter</li><li>Helena Boger</li><li>Helena Lien</li><li>Henning Jølstadengen</li><li>Henning Løvstad</li><li>Henrik Karlsen</li><li>Henrik Lien</li><li>Henrik Linløkken</li><li>Henrik Alexander Bjørhall</li><li>Henry Phung</li><li>Henry Phung</li><li>Herlof Herlofsen</li><li>Herman Kopstad Berentsen</li><li>Herman Snare</li><li>Hermine Riise Kristiansen</li><li>Håkon Myklebust Haakensen</li><li>Håvar Kristoffersen</li><li>Ibrahim Zulfiqar Butt</li><li>Ibrahim Zulfiqar Butt</li><li>Ida Kristiane Espejord</li><li>Ida Sørå Johansen</li><li>Ilson Monteiro Delgado</li><li>Ina Rødningsby Olsen</li><li>Ine Olaisen Romundgard</li><li>Inga Bækholt Resløkken</li><li>Ingeborg Frost Hauge</li><li>Inger Wold</li><li>Isabell-Ann Deposoy Teige</li><li>Isak Gahrmaker Hjermstad</li><li>Iselin Østern</li><li>Ivar Olaf Peereboom</li><li>Ivo Krogsæter Bollum</li><li>Jakob Bangsund</li><li>Jamie  Bjørnstad O&#39;Neill</li><li>Jan Nathaniel Velten</li><li>Jan Tomas Barton</li><li>Jason Aaron Davidson</li><li>Jens-Harald Johansen</li><li>Jerry Sara Promwut</li><li>Jesper Johan Linckert</li><li>Jimmy Nguyen</li><li>Johan Klever</li><li>Johan Laake</li><li>Johannes Aspvik</li><li>Johannes Berg</li><li>Johnny Phung</li><li>Jon Petter Harwiss</li><li>Jonas Levander Alfredsen</li><li>Jonas Vågåsar</li><li>Jonas Emil Skaug</li><li>Jonas Gilleberg Toftenes</li><li>Jonathan Hagberg Nor</li><li>Jonathan Elias Holme</li><li>Jonathan Moen Holmen</li><li>Julian Domagala</li><li>Julian Van Ek Østbye</li><li>Julie Ekhøy</li><li>Julie Huynh Scharff</li><li>Juliette Ihlang</li><li>Jurijs Fjodorovs</li><li>Jørgen Daland Bjørnsen</li><li>Jørgen Granum Nordahl</li><li>Jørgen stray Guttormsen</li><li>Jørn Grotnes</li><li>Karina Nygaard Øynes</li><li>Karl Kristian Indreeide</li><li>Karl Vegar Larsen</li><li>Karoline Nyhammer</li><li>Katarina Murphy</li><li>Katarzyna Krohn</li><li>Katelam Ha</li><li>Kenneth Duong</li><li>Kenneth Groth</li><li>Kenneth Kronstad</li><li>Kenneth Paulsen</li><li>Kenny Huynh</li><li>Kent André Grebstad</li><li>Kevin Duong</li><li>Kim Ronnie Sandnes</li><li>Kine Lunde</li><li>Kine Skrimstad</li><li>Kjeran Peereboom</li><li>Knut Lauritzen</li><li>Kristian Johansen</li><li>Kristian Olaussen</li><li>Kristian Rifseim</li><li>Kristin Eljevåg</li><li>Kuba Pawlowski</li><li>Kurt Steinar Johansen</li><li>Kåre A. Brustad</li><li>Lakshman Senthil</li><li>Lars Erling Bråten</li><li>Leah Corneliussen</li><li>Leah Corneliussen</li><li>Leander Øyen Hejtmanek</li><li>Leif Stavseth</li><li>Leif-Arne Kristiansen</li><li>Leila Ibragimovna Dzortova</li><li>Leon Schrøder Spolén</li><li>Lilja Lamont</li><li>Lilly Sara Promwut</li><li>Linnea Christiansen</li><li>Linnea Amalie Bredesen Nybak</li><li>Lisa Sara Promwut</li><li>Lucas Fagerlund</li><li>Lucas Lyhus</li><li>Ludvig Smedbråten</li><li>Lukas Berntsen</li><li>Maatii G Ebsa</li><li>Mads Gjevert Pettersen</li><li>Magne-Vegard Merkesdal</li><li>Magnus Lekvold</li><li>Magnus Le Tøftum</li><li>Magnus Sebastian Sølvesen-Myhre</li><li>Maja Kumor</li><li>Maja Tørstad Johnsrud</li><li>Makana Corneliussen</li><li>Marco Antonio Arias-Brunet</li><li>Marcus Berg</li><li>Marcus Aleksander Berg</li><li>Marcus Westvang Andreassen</li><li>Marie Estelle Blengsli</li><li>Marita Rudi</li><li>Marius Frang</li><li>Marius Gausel</li><li>Marius Klever</li><li>Marius Kløften</li><li>Marius Nystuen Sveen</li><li>Marius Skjervold</li><li>Marius Blesvik Dahlen</li><li>Marius Gjevert Pettersen</li><li>Markas Krasauskas</li><li>Markus Ertesvåg</li><li>Markus Hertaas</li><li>Markus Aleksander Opheimsjorde Henriksen</li><li>Martin Berge</li><li>Martin Jonassen</li><li>Martin Pham Do</li><li>Martin Vågåsar</li><li>Martin Frilseth Grønvold</li><li>Martin Schilling Lier</li><li>Mathias Grødtlien</li><li>Mathias Dahl Bråten</li><li>Mathias Dahl Bråten</li><li>Mathilde Gripp</li><li>Mathilde Skrimstad</li><li>Mathushan Senthil</li><li>Matias Leunell Enger</li><li>Mats Evensen</li><li>Mats Tørstad Johnsrud</li><li>May Kristin Lyamouri Bredahl</li><li>Maya Bangsund</li><li>Maya Eilertsen</li><li>Medin Buvik</li><li>Michael Nepomuceno</li><li>Mikkel Lauritsen</li><li>Mille Frenning</li><li>Mina Riis</li><li>Minh Dy Le</li><li>Minh Dy Le</li><li>Momin Zulfiqar Butt</li><li>Momin Zulfiqar Butt</li><li>Morten Endreson</li><li>Morten Jacobsen</li><li>Morten Linløkken</li><li>Morten Linløkken</li><li>Muazzam Abdumalikova</li><li>Muhammad Lutf Muhammad</li><li>Muhammed Gøksu</li><li>Muzamel Waziri</li><li>Nadzhi Aliev Aliev</li><li>Nanette N.M. Eriksen</li><li>Natalie Millenberg</li><li>Natalie Søgård</li><li>Nathalie Skandfer Backer</li><li>Nguyen Huynh</li><li>Nicolai Hagen</li><li>Nita Helene Bratteland Paredes</li><li>Nora Marlén Ulvær</li><li>Odin Kollstrøm</li><li>Ola Kristoffersen</li><li>Ole Arthur Maruzzo Kollien</li><li>Ole-Martin Nordahl</li><li>Oliver Hansen</li><li>Oliver Hibbard</li><li>Oliver Gahrmaker Hjermstad</li><li>Oliver Hørup Kristiansen</li><li>Omèr Hussain</li><li>Oscar Rognlid</li><li>Oskar Karl Flesland</li><li>Osman Bhatti</li><li>Osman Dincer</li><li>Patrick Torp Holt</li><li>Per Stian Vikan</li><li>Per-Frode Pedersen</li><li>Peter Malum Bergerud</li><li>Peter Malum Bergerud</li><li>Petter Gudmundsen</li><li>Phillip Helvig Eriksen</li><li>Phu Chau Nguyen</li><li>Preben Holthe</li><li>Pål Østlie</li><li>Ramiz Bhatti</li><li>Remi Schau</li><li>Roald Freudenberg</li><li>Robert Aapro</li><li>Robin Berg Fabian</li><li>Robin Pereira</li><li>Romerike Jujutsu Klubb</li><li>Ronny Aune</li><li>Rune Wang</li><li>Saidakrom Abdumalikov</li><li>Sander Endresen</li><li>Sara Madelen Musæus</li><li>Sara Sakura Syvertsen</li><li>Scott Jåfs Evensen</li><li>Sebastian Aagren</li><li>Sebastian Glemmestad</li><li>Sebastian Jahren</li><li>Sebastian Mäntylä</li><li>Sebastian Tveter</li><li>Sedsel Fretheim Thomassen</li><li>Shad Rawand</li><li>Shayaan Baig</li><li>Shruti Jhanjee</li><li>Sigrid Nyhammer</li><li>Sigurd Slinning Klausen</li><li>Sigve Paulsen</li><li>Silje Grov</li><li>Simen Schaufel</li><li>Simen Vågåsar</li><li>Siv Margrete Seljeflot</li><li>Sivert Jarmund</li><li>Solveig Irene Sletta</li><li>Sondre Paulsen</li><li>Steffen Sandstad</li><li>Steffen Frost Hauge</li><li>Stian Hegge-Jensen</li><li>Stian Nyblom</li><li>Stian Nyblom</li><li>Storm Sundberg</li><li>Susanne Eggereide</li><li>Svein Michael Hauger-Rolijordet</li><li>Svein Robert Rolijordet</li><li>Tam Le</li><li>Tamara Kujacic</li><li>Tarjei Grønås</li><li>Terje Eriksen</li><li>Test Testesen</li><li>Test2 Testesen</li><li>Thale Strøm</li><li>Thea Buvik</li><li>Thea Wethe Jahrn</li><li>Theo Jørgensen-Dahl</li><li>Theodor A Holme</li><li>Thomas Danglé</li><li>Thomas Gulbrandsen</li><li>Thomas Hauger-Rolijordet</li><li>Thomas Iversen</li><li>Thomas Ødegård</li><li>Thomas Martin Berge</li><li>Thomas Nordlie Lein</li><li>Thor André Hammer Olsen</li><li>Tim Holmen</li><li>Toan Khanh Truong</li><li>Tobias Ramsvik</li><li>Tobias Andrè Berg</li><li>Tobias Johan Aune</li><li>Tom Gulbrandsen</li><li>Tom Halvorsen</li><li>Tom Arild Knapkøien</li><li>Tom Erik Strøm</li><li>Tomas Lindgaard</li><li>Tomas Nyblom</li><li>Tomas Tangen</li><li>Tommy Lohne</li><li>Tommy Musæus</li><li>Tone Holm</li><li>Torben Græsdal</li><li>Torbjørn Sjåberg</li><li>Torbjørn Kamer Smits</li><li>Tore Skålshegg</li><li>Tran Ba Luan</li><li>Trine Eggen Bodeng</li><li>Trine Schilling Lier</li><li>Tristan Troy Rasay</li><li>Trygve Sigvartsen</li><li>Trygve Bækholt Resløkken</li><li>Tuan Anh Le</li><li>Ukko Laitinen</li><li>Ulf Ekhøy</li><li>Una Benedicte Henriksen</li><li>Vebjørn Knutsen</li><li>Vegar Norman</li><li>Vegard Dahlen</li><li>Vegard Østnes</li><li>Vetle Tenold Frisk</li><li>Vetle Færgestad Gulbrandsen</li><li>Victor Aas Karlstad</li><li>Victor Noah Krohn</li><li>Victoria Engen</li><li>Victoria Amber Engen</li><li>Viet Huynh</li><li>Viktor Golke</li><li>Yahya Zulfiqar Butt</li><li>Youlian Ivanov Prodanov</li><li>Yvonne Helen Rasch</li><li>Zdenek Barton</li><li>Zurab Kerimov</li><li>fehzan ali</li><li>kevin le</li><li>kevin le</li><li>vegard olsson</li><li>Émil Tran</li><li>Øivind Paulshus</li></ul>
      <h2>Ville ha oppdatert følgende medlemmer hos NKF (3)</h2>
      <ul>
        <li>Lars Bråten<ul>
          <li>{:membership=&gt;:left_on}: &quot;31.03.2020&quot; => &quot;&quot;</li>
        </ul></li>
        <li>Sebastian Kubosch<ul>
          <li>{:membership=&gt;:left_on}: &quot;01.10.2019&quot; => &quot;&quot;
        </li></ul></li>
        <li>Uwe Kubosch<ul>
          <li>{:user=&gt;:contact_email}: &quot;uwe@kubosch.no&quot; => &quot;uwe@example.com&quot;</li>
          <li>{:membership=&gt;:joined_on}: &quot;15.12.2000&quot; => &quot;05.01.1987&quot;</li>
          <li>{:user=&gt;:male}: &quot;Mann&quot; =&gt; &quot;M&quot;</li>
          <li>{:user=&gt;:phone}: &quot;92206046&quot; => &quot;55569666&quot;</li>
          <li>{:membership=&gt;:discount}: &quot;&quot; => &quot;100&quot;</li>
         </ul></li>
      </ul>
      <style type="text/css">.card {\r
        border: 1px solid black;\r
        margin-bottom: 1rem;\r
        margin-top: 1rem;\r
        padding: 1rem;\r
      }</style>
      <h2>Feil (7)</h2>
      <a href="https://example.com/nkf_members/sync_errors">Show sync Errors</a>
      <div class="card">
        <h3>1. Operation: New member</h3>
        <h4>Exception:</h4>
        <pre>Det oppstod feil: Telefon er for kort (minimum 8 tegn)</pre>
        <h4>Record:</h4>
        <a href="https://example.com/nkf_members/819792662">#&lt;NkfMember id: 819792662, member_id: nil, medlemsnummer: 1117968, etternavn: "Zahroni", fornavn: "Kevin", adresse_1: "", adresse_2: "Støperiveien 38", adresse_3: "", postnr: "2010", sted: "STRØMMEN", fodselsdato: "25.01.2009", telefon: "98101927", telefon_arbeid: "", mobil: "", epost: "phuong.ahus111@gmail.com", epost_faktura: "", yrke: "Skoleelev/student", medlemsstatus: "U", medlemskategori: "783", medlemskategori_navn: "Ungdom", kont_sats: "Ungdom", kont_belop: "250", kontraktstype: "Ungdom", kontraktsbelop: "349", rabatt: "", gren_stilart_avd_parti___gren_stilart_avd_parti: "Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømm...", sist_betalt_dato: "15.04.2020", betalt_t_o_m__dato: "31.03.2021", konkurranseomrade_id: nil, konkurranseomrade_navn: nil, klubb_id: "1034", klubb: "Romerike Jujutsu Klubb", hovedmedlem_id: 1117968, hovedmedlem_navn: "Zahroni  Kevin", innmeldtdato: "26.09.2019", innmeldtarsak: "PO", utmeldtdato: "30.04.2020", utmeldtarsak: "", antall_etiketter_1: "", created_at: "2013-10-17 16:46:00", updated_at: "2013-10-17 16:46:00", ventekid: nil, kjonn: "Mann", foresatte: "Phuong Nguyen", foresatte_epost: "phuong.ahus111@gmail.com", foresatte_mobil: "98101927", foresatte_nr_2: "Phuong nguyen", foresatte_nr_2_mobil: "9810127", hoyde: 141&gt;</a>
      </div>
      <div class="card">
        <h3>2. Operation: New member</h3>
        <h4>Exception:</h4>
        <pre>Det oppstod feil: Telefon er for kort (minimum 8 tegn)</pre>
        <h4>Record:</h4>
        <a href="https://example.com/nkf_members/819792406">#&lt;NkfMember id: 819792406, member_id: nil, medlemsnummer: 1024894, etternavn: "Jemmali", fornavn: "Lilia", adresse_1: "", adresse_2: "Elgtråkket 9 D", adresse_3: "", postnr: "2014", sted: "BLYSTADLIA", fodselsdato: "19.07.2000", telefon: "63 83 21", telefon_arbeid: "", mobil: "99 53 54", epost: "lassadjemmali@live.no", epost_faktura: "lassadjemmali@live.no", yrke: "", medlemsstatus: "U", medlemskategori: "783", medlemskategori_navn: "Ungdom", kont_sats: "Ungdom", kont_belop: "250", kontraktstype: "Ungdom", kontraktsbelop: "349", rabatt: "", gren_stilart_avd_parti___gren_stilart_avd_parti: "Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømm...", sist_betalt_dato: "15.10.2013", betalt_t_o_m__dato: "31.03.2014", konkurranseomrade_id: nil, konkurranseomrade_navn: nil, klubb_id: "1034", klubb: "Romerike Jujutsu Klubb", hovedmedlem_id: 1024894, hovedmedlem_navn: "Jemmali Lilia", innmeldtdato: "26.09.2011", innmeldtarsak: "PO", utmeldtdato: "30.11.2013", utmeldtarsak: "", antall_etiketter_1: "", created_at: "2013-10-17 16:46:00", updated_at: "2013-10-17 16:46:00", ventekid: "33300000000010248941", kjonn: "Kvinne", foresatte: "Lassad Jemmali", foresatte_epost: "", foresatte_mobil: "", foresatte_nr_2: "", foresatte_nr_2_mobil: "", hoyde: 152&gt;</a>
      </div>
      <div class="card">
        <h3>3. Operation: New member</h3>
        <h4>Exception:</h4>
        <pre>Det oppstod feil: Telefon er for kort (minimum 8 tegn)</pre>
        <h4>Record:</h4>
        <a href="https://example.com/nkf_members/819792597">#&lt;NkfMember id: 819792597, member_id: nil, medlemsnummer: 1011955, etternavn: "Soleng", fornavn: "Maja", adresse_1: "", adresse_2: "Ramstadåsen 18", adresse_3: "", postnr: "1900", sted: "FETSUND", fodselsdato: "01.08.1998", telefon: "63881311", telefon_arbeid: "", mobil: "46669412", epost: "zanetta@soleng.us", epost_faktura: "", yrke: "Skoleelev/student", medlemsstatus: "U", medlemskategori: "783", medlemskategori_navn: "Ungdom", kont_sats: "Ungdom", kont_belop: "250", kontraktstype: "Ungdom - familie", kontraktsbelop: "299", rabatt: "", gren_stilart_avd_parti___gren_stilart_avd_parti: "Aikido/Aikikan Norge/Strømmen Storsenter/Junior ai...", sist_betalt_dato: "15.12.2010", betalt_t_o_m__dato: "31.03.2011", konkurranseomrade_id: nil, konkurranseomrade_navn: nil, klubb_id: "1034", klubb: "Romerike Jujutsu Klubb", hovedmedlem_id: 1011955, hovedmedlem_navn: "Soleng Maja", innmeldtdato: "13.09.2010", innmeldtarsak: "PO", utmeldtdato: "31.12.2010", utmeldtarsak: "", antall_etiketter_1: "", created_at: "2013-10-17 16:46:00", updated_at: "2013-10-17 16:46:00", ventekid: "33300000000010119555", kjonn: "Kvinne", foresatte: "Zanetta W. Soleng", foresatte_epost: "zanetta@soleng.us", foresatte_mobil: "9979096", foresatte_nr_2: "", foresatte_nr_2_mobil: "", hoyde: 156&gt;</a>
      </div>
      <div class="card">
        <h3>4. Operation: New member</h3>
        <h4>Exception:</h4>
        <pre>Det oppstod feil: Telefon er for kort (minimum 8 tegn)</pre>
        <h4>Record:</h4>
        <a href="https://example.com/nkf_members/819792663">#&lt;NkfMember id: 819792663, member_id: nil, medlemsnummer: 1117969, etternavn: "Zahroni", fornavn: "Sebastian", adresse_1: "", adresse_2: "Støperiveien 38", adresse_3: "", postnr: "2010", sted: "STRØMMEN", fodselsdato: "25.01.2009", telefon: "98101927", telefon_arbeid: "", mobil: "", epost: "phuong.ahus111@gmail.com", epost_faktura: "", yrke: "Skoleelev/student", medlemsstatus: "U", medlemskategori: "783", medlemskategori_navn: "Ungdom", kont_sats: "Ungdom", kont_belop: "250", kontraktstype: "Ungdom - familie", kontraktsbelop: "299", rabatt: "", gren_stilart_avd_parti___gren_stilart_avd_parti: "Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømm...", sist_betalt_dato: "15.04.2020", betalt_t_o_m__dato: "31.03.2021", konkurranseomrade_id: nil, konkurranseomrade_navn: nil, klubb_id: "1034", klubb: "Romerike Jujutsu Klubb", hovedmedlem_id: 1117969, hovedmedlem_navn: "Zahroni  Sebastian", innmeldtdato: "26.09.2019", innmeldtarsak: "PO", utmeldtdato: "30.04.2020", utmeldtarsak: "", antall_etiketter_1: "", created_at: "2013-10-17 16:46:00", updated_at: "2013-10-17 16:46:00", ventekid: nil, kjonn: "Mann", foresatte: "Phuong Nguyen", foresatte_epost: "phuong.ahus111@gmail.com", foresatte_mobil: "98101927", foresatte_nr_2: "Phuong nguyen", foresatte_nr_2_mobil: "9810127", hoyde: 146&gt;</a>
      </div>
      <div class="card">
        <h3>5. Operation: New member</h3>
        <h4>Exception:</h4>
        <pre>Det oppstod feil: Fødselsdato er ikke inkludert i listen</pre>
        <h4>Record:</h4>
        <a href="https://example.com/nkf_members/819792584">#&lt;NkfMember id: 819792584, member_id: nil, medlemsnummer: 1119280, etternavn: "Singh", fornavn: "Sukhvir", adresse_1: "", adresse_2: "Karisveien 191", adresse_3: "", postnr: "2013", sted: "SKJETTEN", fodselsdato: "01.01.1900", telefon: "", telefon_arbeid: "", mobil: "", epost: "geirr@cranner.com", epost_faktura: "geirr@cranner.com", yrke: "", medlemsstatus: "U", medlemskategori: "784", medlemskategori_navn: "Voksen", kont_sats: "Voksen", kont_belop: "250", kontraktstype: "Voksen", kontraktsbelop: "399", rabatt: "", gren_stilart_avd_parti___gren_stilart_avd_parti: "Aikido/Aikikan Norge/Strømmen Storsenter/Aikido Vo...", sist_betalt_dato: "16.12.2019", betalt_t_o_m__dato: "31.03.2020", konkurranseomrade_id: nil, konkurranseomrade_navn: nil, klubb_id: "1034", klubb: "Romerike Jujutsu Klubb", hovedmedlem_id: 1119280, hovedmedlem_navn: "Singh Sukhvir", innmeldtdato: "14.10.2019", innmeldtarsak: "PO", utmeldtdato: "31.12.2019", utmeldtarsak: "", antall_etiketter_1: "", created_at: "2013-10-17 16:46:00", updated_at: "2013-10-17 16:46:00", ventekid: nil, kjonn: "Mann", foresatte: "Geirr Delphin Cranner", foresatte_epost: "", foresatte_mobil: "", foresatte_nr_2: "", foresatte_nr_2_mobil: "", hoyde: 160&gt;</a>
      </div>
      <div class="card">
        <h3>6. Operation: New member</h3>
        <h4>Exception:</h4>
        <pre>Det oppstod feil: Fødselsdato er ikke inkludert i listen</pre>
        <h4>Record:</h4>
        <a href="https://example.com/nkf_members/819792623">#&lt;NkfMember id: 819792623, member_id: nil, medlemsnummer: 1059831, etternavn: "Testesen", fornavn: "Test3", adresse_1: "", adresse_2: "", adresse_3: "adresselinje 2", postnr: "2013", sted: "SKJETTEN", fodselsdato: "01.01.1900", telefon: "", telefon_arbeid: "", mobil: "", epost: "test3@example.com", epost_faktura: "", yrke: "", medlemsstatus: "U", medlemskategori: "782", medlemskategori_navn: "Barn", kont_sats: "Barn", kont_belop: "170", kontraktstype: "Barn", kontraktsbelop: "284", rabatt: "", gren_stilart_avd_parti___gren_stilart_avd_parti: "Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømm...", sist_betalt_dato: "", betalt_t_o_m__dato: "", konkurranseomrade_id: nil, konkurranseomrade_navn: nil, klubb_id: "1034", klubb: "Romerike Jujutsu Klubb", hovedmedlem_id: 1059831, hovedmedlem_navn: "Testesen Test3", innmeldtdato: "01.01.2014", innmeldtarsak: "PO", utmeldtdato: "01.01.2014", utmeldtarsak: "", antall_etiketter_1: "", created_at: "2013-10-17 16:46:00", updated_at: "2013-10-17 16:46:00", ventekid: "33300000000010598311", kjonn: "Mann", foresatte: "", foresatte_epost: "", foresatte_mobil: "33333333", foresatte_nr_2: "", foresatte_nr_2_mobil: "", hoyde: 180&gt;</a>
      </div>
      <div class="card">
        <h3>7. Operation: New member</h3>
        <h4>Exception:</h4>
        <pre>Det oppstod feil: Telefon er for kort (minimum 8 tegn)</pre>
        <h4>Record:</h4>
        <a href="https://example.com/nkf_members/819792598">#&lt;NkfMember id: 819792598, member_id: nil, medlemsnummer: 1011954, etternavn: "Soleng", fornavn: "Zanetta W.", adresse_1: "", adresse_2: "Ramstadåsen 18", adresse_3: "", postnr: "1900", sted: "FETSUND", fodselsdato: "17.11.1970", telefon: "63881311", telefon_arbeid: "", mobil: "9979096", epost: "zanetta@soleng.us", epost_faktura: "", yrke: "", medlemsstatus: "U", medlemskategori: "784", medlemskategori_navn: "Voksen", kont_sats: "Voksen", kont_belop: "250", kontraktstype: "Voksen", kontraktsbelop: "399", rabatt: "", gren_stilart_avd_parti___gren_stilart_avd_parti: "Aikido/Aikikan Norge/Strømmen Storsenter/Seniorer ...", sist_betalt_dato: "15.12.2010", betalt_t_o_m__dato: "31.03.2011", konkurranseomrade_id: nil, konkurranseomrade_navn: nil, klubb_id: "1034", klubb: "Romerike Jujutsu Klubb", hovedmedlem_id: 1011954, hovedmedlem_navn: "Soleng Zanetta W.", innmeldtdato: "13.09.2010", innmeldtarsak: "PO", utmeldtdato: "31.12.2010", utmeldtarsak: "", antall_etiketter_1: "", created_at: "2013-10-17 16:46:00", updated_at: "2013-10-17 16:46:00", ventekid: "33300000000010119548", kjonn: "Kvinne", foresatte: "", foresatte_epost: "", foresatte_mobil: "", foresatte_nr_2: "", foresatte_nr_2_mobil: "", hoyde: 169&gt;</a>
      </div>
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

      diff << "#{"#{change} #{node.to_html}".ljust(30)} #{node.parent.path}\n"
    end
    assert_empty diff, -> { "#{diff}\n#{Nokogiri::XML(mail.body.decoded, &:noblanks)}" }

    # assert_dom_equal(changes, body)
    mail = ActionMailer::Base.deliveries[2]
    assert_equal 'Verv fra NKF: 10', mail.subject
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
          <td>Bastian\ Filip\ Krohn</td>\s*
          <td>Kasserer\ \(2\ år\)</td>\s*
          <td>2015-02-12</td>\s*
          <td></td>
        }x,
        mail.body.decoded
    assert_equal [
      '<tr> <th align="left">Verv</th> <th>Navn</th> <th>Fra</th> <th>Til</th> </tr>',
      '<tr> <td>Uwe Kubosch</td> <td>Hovedinstruktør</td> <td>2013-01-01</td> <td></td> </tr>',
      '<tr> <td>Scott Jåfs Evensen</td> <td>Nestleder</td> <td>2015-02-12</td> <td>2017-02-28</td> </tr>',
      '<tr> <td>Bastian Filip Krohn</td> <td>Kasserer (2 år)</td> <td>2015-02-12</td> <td></td> </tr>',
      '<tr> <td>Bastian Filip Krohn</td> <td>Kasserer (2 år)</td> <td>2015-02-12</td> <td></td> </tr>',
      '<tr> <td>Sara Madelen Musæus</td> <td>Materialforvalter</td> <td>2015-02-12</td> <td>2018-03-15</td> </tr>',
      '<tr> <td>Inga Bækholt Resløkken</td> <td>Ungdomsrepresentant</td> <td>2015-02-12</td> <td>2017-02-28</td> </tr>',
      '<tr> <td>Tommy Musæus</td> <td>Materialforvalter</td> <td>2018-03-15</td> <td></td> </tr>',
      '<tr> <td>Atle Tollefsen</td> <td>Påmeldingsansvarlig</td> <td>2018-03-21</td> <td>2018-12-31</td> </tr>',
      '<tr> <td>Atle Tollefsen</td> <td>Medlemsansvarlig</td> <td>2018-03-21</td> <td>2018-12-31</td> </tr>',
      '<tr> <td>Curt Mekiassen</td> <td>Medlem</td> <td>2019-03-24</td> <td></td> </tr>',
    ], mail.body.decoded.gsub(/\s+/, ' ').scan(%r{<tr>.*?</tr>}m)
  end
end
