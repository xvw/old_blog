% Proposition d'un formalisme sur la gestion de la réputation dans un jeux d'aventure
% Xavier Van de Woestyne
% Juillet 2015

> Tenter de créer des jeux-vidéos ou des systèmes en relation avec le jeux-vidéo est un passe temps qui m'amuse encore assez souvent. Cet article proposera une réflexion sur l'implémentation (mais surtout le formalisme) d'un système de réputation basé sur *beaucoup* trop de critères pour être réellement utilisable. L'intérêt principal de cet article (à mon humble avis) est de dresser une liste potentiellement exhaustive des mécaniques à raisonner en cas d'audace de ma part, me poussant à tenter d'implémenter ce genre d'outil pour un jeux-vidéo. L'idée de cet article est issu d'une conversation avec **Ulis** et raffraîchit une vieille conversation avec **Mickaël Spawn**.

Il est courant de voir dans les RPG's (généralement occidentaux, je l'accorde),
des mécanismes de réputation, alignant un personnage (jouable) en fonction
de ses actions. Même si les deux pôles offrent généralement des avantages, la
construction d'une mécanique de réputation fiable est relativement (de mon
point de vue) complexe !

### L'approche naïve
Cette manière de concevoir une réputation pour le joueur ne sera pas réellement
détaillée car, comme son nom l'indique, elle est naïve et ne présente *pas
assez d'intérêt* pour être la seule formule proposée dans cet article.\
L'idée est de construire deux compteurs d'actions:

*    L'un pour les bonnes actions;
*    L'autre pour les mauvaises actions.

Une fonction d'alignement général est possible, cependant, l'avantage de cette
méthode est qu'elle permet d'adapter la fonction d'alignement par intervenant.
On peut donc rapidement simuler plusieurs réactions à un corpus d'actions
réalisées par le joueur.

#### Quelques fonctions d'alignement
Où *f* est un des deux corpus (quelconque) et *ba* est le corpus des bonnes actions et *ma* est le corpus des mauvaises actions. (A noter que les fonctions
peuvent être littéralement inversées pour changer la direction de l'état de la
réputation. Par exemple, le jugement d'un pervers). On peut éventuellement
introduire un opérateur *n* qui indique le nombre d'actions effectuées (ce qui
introduit par extension le fait qu'une action est pondérée).\
Attention, ces *fonctions* sont extrèmement simples !

| Nomination | Formule |
|---|---|
| Observation constante | $f > x$ |
| Le positif | $ba > ma$ |
| Le tolérant par rapport à *x*| $ba / (n(ba + ma) > x$  |
| L'absolument intolérant | $ma > 0$ |
| Coefficient absolu | $(ma - ba)/n(ba + ma)$ |

Il n'existe pas vraiment de limite dans la définition de fonctions d'alignement
et c'est au développeur de les construire en fonction de l'effet voulu.
Bien que cette méthode soit présentée comme *naïve*, elle offre tout de même
des embranchements potentiellement complexes.

#### Bénéficier de la géolocalisation
Une approche plus raffinée serait de ne pas se contenter de deux variables
(et éventuellement leurs compteurs) mais de stocker dans un tableaux ces données
pour pouvoir donner une dimension spatiale à la réputation. Admettant que les
individus d'une région **B** ne soient pas au courant des méfaits que le joueur
aurait effectué dans une région **A**. Un tel usage permettrait, en plus,
d'admettre une potentielle conversations entre certaines membres de chaques
régions en se servant d'une proximité géographique. 

#### Constat
On remarque tout de même que la méthode dite *naïve* offre des perspectives
de personnalisation impressionnante et peut sans aucun mal, être une
extension de *GamePlay* très expressive.\
Par contre, même en créant un tableau de réputation et en les chaînant, on
admet une mémoire collective aux individus des différentes régions. Or, il
est évidemment possible de segmenter, avec plus de finesse, la notion de
réputation, pour que l'interprétation du personnage non joueur se repose sur
plus de critères.

## Distinction entre réputation et Karma
Dès lors que les corpus d'action ont une influence générale, on outrepasse
la notion "simple" de réputation pour s'apparenter (un peu) à celle du Karma.
Soit que le destin agisse ou non en notre faveur est lié par le corpus des
actions passées. Dans cet article, on préférerait imaginer un système de
réputation entretenant une étroite corélation d'individu à individu, ce qui
permet plus de finesse (et de réalisme, même si la quête du réalisme n'est
pas notre objectif premier) lors de la génération du comportement d'un
intervenant. Une approche d'individu à individu permet de créer des groupes
réactionnaires et d'impliquer la notion de Karma (en fonction de l'envie
du développeur de donner une portée macroscopique aux actes de ses joueurs).

> Comme l'enjeu premier de cet article est de proposer un modèle de relation inférant un système de réputation, il est important de donner à la réputation une notion *one by one*. Que la réputation ait donc, premièrement, une portée directe avec l'intervenant, et qu'elle puisse, éventuellement, selon certains critères, projeter des caractéristiques complémentaires sur d'autres intervenants.

Pour étendre la portée des bonnes et mauvaises actions, il faut imaginer (la
formalisation sera pour plus tard) que les agents du système de réputation
entretiennent une potentielle relation. Un simple tableau de réputations ne
suffit donc pas.

## Formalisme sur la notion même de réputation et d'actions
De bonnes et de mauvaises actions peuvent être simplement perçus comme des
jauges (pas obligatoirement communiquantes, comme il a été mis en lumière lors
des fonctions d'alignements).\
En admettant une typologie d'action, on peut proposer quelques schémas de
raisonnement par l'intervenant (NPC).

### L'action constatable

![](../images/action-constatable.png)

Cette action, qu'elle soit bonne ou mauvaise, introduit plusieurs variables; en
effet, le cas trivial est que l'action est constatée, et on laisse au
développeur le loisir d'implémenter la réaction du NPC à sa convenance. Là
où cette structure est, à mon sens, intéressante, c'est en cas de
non-constatation de l'action. Dans ce genre de scénario, soit on admet que
le NPC ne veut pas tirer de conclusion, et dans ce cas, on augmente tout de
même une jauge d'inférence.

> Les jauges d'inférences sont isomorphes aux corpus d'actions. Elles permettent de donner une sémantique d'accumulation aux raisonnements sur les actions des NPC.

En cas de jugement (par exemple si la jauge d'un NPC *sature* le NPC émet une
opinion et altère le corpus en conséquence.\
Bien que cette forme d'action introduise une notion de position spatiale
(paramètre initiale de constatation), les inférences permettent de créer un
réseau d'intèrprétation.

### L'action évoquée

![](../images/action-evoquee.png)
