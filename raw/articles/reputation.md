% Proposition d'un formalisme sur la gestion de la réputation dans un jeux d'aventure
% Xavier Van de Woestyne
% Juillet 2015

> Tenter de créer des jeux-vidéos ou des systèmes en relation avec le jeux-vidéo est un passe temps qui m'amuse encore assez souvent. Cet article proposera une réflexion sur l'implémentation (mais surtout le formalisme) d'un système de réputation basé sur *beaucoup* trop de critères pour être réellement utilisable. L'intérêt principal de cet article (à mon humble avis) est de dresser une liste potentiellement exhaustive des mécaniques à raisonner en cas d'audace de ma part, me poussant à tenter d'implémenter ce genre d'outil pour un jeux-vidéo. L'idée de cet article est issu d'une conversation avec **Ulis** et raffraîchit une vieille conversation avec **Mickaël Spawn**. L'idée de cet article n'est pas de proposer une implémentation concrètes mais de réfléchir aux points essentiels pour un système de réputation *idéal* (ce terme est à prendre avec des pincettes), il est probable qu'il soit inimplémentable.

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
De bonnes et de mauvaises actions peuvent être simplement perçues comme des
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

Elle est concrètement l'entrée de la sortie d'une autre action. La notion
d'entropie offre le phénomène connu du *téléphone sans fil* et permet, au
moyen d'un point de vue (qui peut avoir absolument la même forme qu'une
fonction d'alignement) d'altérer l'opinion que le NPC peut avoir sur une action,
qu'elle soit bonne ou mauvaise.\
Au contraire d'une action constatable, une action évoquée peut être le
résultat d'une inférence. Il est donc imaginable que le joueur soit victime
d'altération du jugement d'autrui.

#### Relai alternatif
La notion *d'action évoquée* introduit l'idée sous-jacente que l'univers du
jeu est sujet à un système relationnels fort. Au contraire des contes merveilleux, où le conteur peut justifier toute transmission de savoir par un
subterfuge magique, dans le jeux-vidéo, on peut "narrativement" se servir de
ce genre d'astuce, mais il faut impérativement une implémentation qui tienne
la route.\
Par soucis de rigueure, on peut supposer que l'intérprétation effectuée dans
une action évoquée introduise un jugement par rapport à l'action, mais aussi
par rapport à la personne.

## Les faiblesses de la rigueure
Même si, plus qu'être de la rigueure, cette réflexion sur la réputation penche
vers le phantasme (*mal placé*), on se rend rapidement compte que la modelisation cohérente d'un système de relation et de communication est
drastiquement complexe. On pourrait facilement se servir de graphes dirigés
pour implémenter le modèle relationnel, cependant, il faudrait impérativement
encoder les relations minimales. Ce qui est un travail bien trop lourd pour
être viable.\
Observons par exemple quelques catégories inter-connectables :

*   La cellule familiale;
*   la géoposition;
*   la profession;
*   les communications entre les géopositions;
*   l'affinité;

Je ne pense pas avoir été spécialement exhaustif mais il en ressort tout de
même un travail de classification assez lourd.

### L'interaction scénarisée
Il est évident, que dans un RPG, il n'existe d'interaction que si elles sont
scénarisées. A ce titre, les intervenants seront invariablement atomiques. Par
exemple, deux personnages intervenant tous deux n'assumeront, à deux, que les
propriétés d'un seul. \
Même s'il est envisageable qu'un réseaux d'agents se complexifie au fil du
jeu, pour créer des genres de relations, articuler l'évolution d'un personnage
en admettant une cohérence de la propagation d'information est beaucoup trop
complexe.

## A l'intersection de la naïveté et du réalisme : conclusion
Concrètement, une solution se voulant réaliste est sans aucun doute implantable, cependant, les contraintes de paramétrages seraient beaucoup trop
lourdes pour être (de mon point de vue) assumables. A ce titre, je propose en
conclusion de ce très léger article une structure hybride.

### Structure générale d'un flux de réputation
Comme dans les cas évoqués, on suggère deux compteurs de réputation. L'un étant
pour les bonnes actions, l'autre pour les mauvaises.\
On couple ces deux modèles de deux autres modèles respectivement isomorphes
proposant un indice de confiance pour chaque jauge, permettant de traiter les
cas d'action constatées sans flagrant délit.

### Variables complémentaires
Pour simuler la mécanique d'introspection réfléchies sur les actions, je propose
d'attribuer une règle de portée (en plus de la pondération) aux actions. Ce
qui, en plus de l'automate décrit plus haut, pour toute action propose :

*   Un alignement général (bon ou mauvais);
*   une pondération de l'action;
*   une portée.

L'idée de la portée est qu'elle permet de toucher des ensembles d'individus
précédemment définis. Via la portée, chaque NPC peut, selon la liberté du
développeur, interprêté à sa convenance l'alignement d'une action spécifique.
De ce fait, on retrouve, en plus des jauges générales, des jauges spécifiques
à chaque NPC. L'outillage de configuration en devient moins lourd.

### Conclusion
L'intersection entre les deux schémas est certes, moins réaliste que celle
proposée. Cependant, elle a l'avantage de rester réalisable sans poser un trop
grand coût de configuration.\
La conception d'un jeux-vidéo en tant qu'amateur/indépendant est une tâche
assez ingrate et complexe. Il faut donc parfois être capable de mettre ses
idéaux/objectifs de côté !\
C'est un article bien court n'était au final qu'une simple suggestion de piste
de réflexion sur le moteur de réputation idéal, il occulte totalement
l'incursion dans le game-play. Il est évident que pour concevoir ce genre
d'outil servant les mécaniques de jeux, il faut les penser comme un système
de jeu ambiant.

Merci de votre lecture, et j'espère avoir l'occasion de proposer des articles
en rapport avec les mécaniques de jeux proposant de réelles implémentations
et des solutions moins floues. 
