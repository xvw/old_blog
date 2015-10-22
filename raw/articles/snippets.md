% Liste de snippets que je trouve utiles
% Xavier Van de Woestyne
% Depuis Octobre 2015

> Sur cette page, je référencerai les morceaux de codes que je trouve utiles.
> Je conçois que pour certaines personnes, beaucoup de ces morceaux ne seront
> pas d'une grande utilité, mais pour ma part, certains m'ont bien aidés !

### Sommaire

*     [Snippets Bash](#bash)
*     [Snippets Git](#git)

## Bash

#### Trouver (et ordonner) les plus grands répertoires/fichiers de mon disque

```bash
su
du -hms $repertoire/* | sort -nr | head
```

#### Afficher rapidement son adresse IP

```bash
wget -q -O - ifconfig.co
```

#### Renvoyer rapidement le status HTTP d'une URL

```bash
curl --write-out "%{http_code}\n" \
--connect-timeout 10 --max-time 20 -s -I \
-L http://www.site.com \
--output /dev/null
```

#### Tuer skype salement

```bash
ps -ax | egrep  '[0-9] skype$' | cut -d " " -f 2 | xargs kill -9
```
La version de Skype de Linux plante souvent (surtout en cas de groupe de
conversations actif). Il faut souvent le redemarrer. Cette ligne permet de ne
pas devoir identifier "manuellement" son PID.

## Git

#### Supprimer les branches locales déjà fusionnées

```bash
git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
```

#### Génère un gitignore (utilisant gitignore.io) pour un projet

```bash
curl https://www.gitignore.io/api/emacs,ocaml > .gitignore
```
Il suffit de séparer les outils/langages par une virgule après `api/`. Cette
ligne repose entièrement sur l'excellent site
[gitignore.io](http://gitignore.io), que je recommande vivement d'utiliser !
