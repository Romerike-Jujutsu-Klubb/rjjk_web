Velkommen til Romerike Jujutsu Klubb sin webapplikasjon.

Du finner CMS sitt medlemsregister på

http://cmsnorge.com/

For å utvikle, teste og kjøre applikasjonen må du installere Ferret:

gem install ferret

Linker til utviklingsverktøy:

http://aptana.com/

DEPLOYMENT:

gem install capistrano

Add a reference to your private key in config/deploy.rb

Design Instruksjon:

        GroupSemester         =>     Semester
    /                                  ^
   V                                  /
Group <= GroupSchedule <= GroupInstructor => Member
                                |
                                V
                              Role(Main/Instructor/Helper)


* Only one responsible per group per semester.
* One or several GroupSchedules

## TODO

* Review link to practice + member instead of attendance
* Role => boolean ASSISTANT
* Add coverage
* Link GroupInstructor to GroupSemesterSchedule
