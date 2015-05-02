RJJK Web
========

## Huskeliste

* FIXME(uwe):  Feil i import fra Brønnøysund!
* Optimere grafer
* Tillate testing uten (Internet) nettverk.
* Oppdatere gems
* Testdekning: 80%
* Penere "Last opp media" på høyresiden.
* Penere "Mitt oppmøte".  Sette knapper over hverandre.
* Legg til "Hvem er på?" med http://faye.jcoglan.com/ruby.html

## Tester

Tester kjøres med

    rake test


## Ytelsestester

Du kan kjøre ytelsestester med

    ./siege.sh
    ./siege_news.sh

Resultatene lagres i

    doc/siege/

## Profiling

* https://github.com/tmm1/rblineprof
* https://github.com/tmm1/stackprof
