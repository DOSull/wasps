;; The MIT License (MIT)
;;
;; Copyright (c) 2020 David O'Sullivan
;;
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without restriction,
;; including without limitation the rights to use, copy, modify, merge,
;; publish, distribute, sublicense, and/or sell copies of the Software,
;; and to  permit persons to whom the Software is furnished to do so,
;; subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included
;; in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
;; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
;; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.

__includes [
  "setup.nls"            ;; model initialisation
  "main.nls"             ;; the main model loop
  "display.nls"          ;; display updates
  "dispersal.nls"        ;; dispersal including calculation of kernels
  "reproduction.nls"     ;; reproduction including needed statistical distros
]

extensions [
  palette                ;; Brewer colour palettes
  profiler               ;; profiling
  rnd                    ;; weighted random draws from lists and agentsets
  vid                    ;; video recording
]

breed [ vizs viz ]       ;; to visualize population mix wild (red) vs GM (blue) across space
breed [ ldd-targets ldd-target ]

globals [
  R-mean
  R-annual               ;; this year's mean R value
  num-subpops            ;; the number of subpopulations (3 in the wasps model)
  total-pop              ;; total population across the landscape
  total-wild             ;; total wild population across the landscape
  total-gm               ;; total GM population across the landscape
  total-sterile          ;; total sterile population across the landscape
  mean-occupancy-rate    ;; the mean population as a proportion of capacity

  total-released

  ;; dispersal related
  total-extent           ;; the total number of patches with any wasps present
  prop-occupied          ;; the proportion of all habitable patches with any wasps present

  pals                   ;; colour palettes for display in the order wild, gm, sterile, total

  ;; subsets of the patches
  the-land               ;; all non-sea patches
  the-sea                ;; all sea patches
  preferred-sites        ;; preferred-sites for LDD dispersal (may be roads or other)
  the-habitable-land     ;; all patches with capacity > 0
  monitoring-area        ;; a subset of patches used to record time series data for model exploration
  grid-release-sites     ;; the sites where releases of GM wasps may occur

  show-contours?
]

patches-own [
  freq                   ;; used to initialise the dispersal kernel
  capacity               ;; carrying capacity
  pop                    ;; total population
  pops                   ;; a list of subpopulations [wild GM sterile]
  next-pops              ;; the populations that will exist next year
  init-pop               ;; initial total population to enable quick restart
  init-pops              ;; initial list of subpopulations to enable quick restart
  R-local                ;; the local R value based on population and capacity constraint (1 - n/k)
  preferred-site?        ;; preferred for LDD
  history                ;; a list recording population history for a patch in the monitoring area
  release-schedule-id    ;; tag indicating in which years releases will occur at this site
  temp
]
@#$#@#$#@
GRAPHICS-WINDOW
190
10
621
442
-1
-1
9.0
1
10
1
1
1
0
0
0
1
0
46
0
46
1
1
1
ticks
100.0

BUTTON
625
17
688
50
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
32
185
65
birth-rate
birth-rate
mortality
4
2.0
0.01
1
NIL
HORIZONTAL

BUTTON
625
54
688
87
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
625
90
688
123
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
621
493
739
538
NIL
total-pop
0
1
11

PLOT
199
449
613
661
Populations
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"total" 1.0 0 -8630108 true "" ""
"wild" 1.0 0 -2674135 true "" ""
"GM" 1.0 0 -13791810 true "" ""
"sterile" 1.0 0 -13840069 true "" ""

SLIDER
15
565
187
598
p-ldd
p-ldd
0
0.01
1.0E-4
0.00001
1
NIL
HORIZONTAL

MONITOR
621
542
740
587
NIL
prop-occupied
3
1
11

SLIDER
13
490
185
523
d-mean
d-mean
0.01
10
2.0
0.01
1
NIL
HORIZONTAL

MONITOR
620
592
758
637
mean-occupancy-rate
mean-occupancy-rate
3
1
11

SLIDER
625
295
744
328
show-pop
show-pop
0
num-subpops
3.0
1
1
NIL
HORIZONTAL

SLIDER
873
147
1044
180
proportion-gm
proportion-gm
0
1
0.0
0.01
1
NIL
HORIZONTAL

BUTTON
627
343
744
377
redraw map
colour-patches\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
625
246
745
279
show-pop?
show-pop?
1
1
-1000

BUTTON
626
149
732
183
NIL
reset-map
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
628
383
743
417
toggle roads
ask ldd-targets [set hidden? not hidden?]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
708
53
847
86
seed
seed
0
1000
10.0
1
1
NIL
HORIZONTAL

SWITCH
707
91
849
124
use-seed?
use-seed?
0
1
-1000

SLIDER
874
70
1039
103
mean-occupancy
mean-occupancy
0
1
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
874
107
1040
140
stdev-occupancy
stdev-occupancy
0
0.5
0.0
0.001
1
NIL
HORIZONTAL

CHOOSER
973
238
1149
283
scenario
scenario
"base plus release sites" "release sites only" "base only"
0

SLIDER
1082
374
1230
407
number-of-sites
number-of-sites
0
2500
10.0
10
1
NIL
HORIZONTAL

TEXTBOX
987
303
1149
321
Release of GM wasps
14
0.0
1

TEXTBOX
877
10
1040
28
Population initialisation
14
0.0
1

SLIDER
977
429
1149
462
colonies-per-site
colonies-per-site
0
max-capacity-per-sq-km * 0.2
16.0
1
1
NIL
HORIZONTAL

SLIDER
977
467
1149
500
percentile-selector
percentile-selector
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
976
592
1148
625
release-type
release-type
0
1
1.0
1
1
NIL
HORIZONTAL

SLIDER
976
504
1149
537
periodicity
periodicity
0
10
2.0
1
1
NIL
HORIZONTAL

SWITCH
15
291
185
324
stochastic-repro?
stochastic-repro?
0
1
-1000

SLIDER
15
421
187
454
var-mean-ratio
var-mean-ratio
1
5
1.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
1235
378
1301
406
how many \nlocations
11
0.0
1

TEXTBOX
1151
426
1258
454
colonies' worth of \nwasps per site
11
0.0
1

TEXTBOX
1152
461
1281
503
where in the habitat\ndistribution to select \nrelease sites
11
0.0
1

TEXTBOX
1152
508
1321
558
how often to release wasps: \n0 =  never (or only at t0)\nn = every n years
11
0.0
1

TEXTBOX
1152
594
1315
650
0 = wild; 1 = GM\nThis should usually be set to 1, but 0 can be used to explore invasion
11
0.0
1

SLIDER
874
30
1100
63
max-capacity-per-sq-km
max-capacity-per-sq-km
100
1000
100.0
10
1
NIL
HORIZONTAL

TEXTBOX
946
182
1051
210
initialise with GM wasps everyhere
11
0.0
1

TEXTBOX
711
21
861
51
For replicability set a seed and use it!
12
0.0
1

SLIDER
12
175
184
208
pop-sd
pop-sd
0
0.5
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
12
105
184
138
mortality
mortality
0
1
1.0
0.001
1
NIL
HORIZONTAL

TEXTBOX
19
69
183
98
New colonies per reproductive queen
11
0.0
1

TEXTBOX
12
12
162
30
Population dynamics
14
0.0
1

TEXTBOX
21
327
190
411
Exp(N) each generation is R * pop. Stochastic option will vary this according to a Poisson distribution (vmr = 1) or a Negative Binomial (vmr > 1)
11
0.0
1

TEXTBOX
9
256
159
286
Stochastic variation in reproduction
12
0.0
1

TEXTBOX
12
468
162
486
Dispersal
14
0.0
1

TEXTBOX
19
527
169
555
Mean distance (exponentially distributed)
11
0.0
1

TEXTBOX
19
600
193
643
Probability of long distance dispersal to a randomly select road location
11
0.0
1

TEXTBOX
631
187
781
215
Reset to manually rerun a particular initial setup
11
0.0
1

TEXTBOX
631
228
781
246
Display
14
0.0
1

TEXTBOX
748
295
898
337
Population to show: 0 = wild, 1 = GM, 2 = sterile, 3 = total
11
0.0
1

TEXTBOX
748
245
898
287
On = show populations\nOff = show red:blue mix of wild:GM
11
0.0
1

TEXTBOX
17
212
167
240
Annual variability in population parameters
11
0.0
1

SLIDER
1120
81
1298
114
distribution-scale
distribution-scale
1
50
30.0
1
1
NIL
HORIZONTAL

CHOOSER
1121
119
1299
164
LDD
LDD
"targetted-roads" "targetted-random" "untargetted"
2

BUTTON
767
590
893
624
NIL
save-monitor
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1125
10
1301
28
Spatial characteristics
14
0.0
1

SWITCH
750
550
893
583
monitor-area?
monitor-area?
1
1
-1000

CHOOSER
1119
30
1299
75
spatial-setup
spatial-setup
"homogeneous" "random-correlated" "e-w-trend"
1

BUTTON
628
425
744
459
show contours
ifelse show-contours?\n[ clear-drawing ] \n[ draw-contours ]\nset show-contours? not show-contours?
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
21
144
171
172
Annual mortality of queens (usu. 1)
11
0.0
1

SWITCH
995
328
1130
361
grid-releases?
grid-releases?
0
1
-1000

SLIDER
913
374
1043
407
grid-resolution
grid-resolution
1
25
2.0
1
1
NIL
HORIZONTAL

MONITOR
748
493
820
538
NIL
total-wild
0
1
11

TEXTBOX
1053
383
1078
401
OR
14
0.0
1

TEXTBOX
632
463
742
481
of habitat capacity
11
0.0
1

CHOOSER
982
543
1144
588
spatial-or-temporal
spatial-or-temporal
"spatial" "temporal"
0

SLIDER
1147
328
1331
361
program-duration
program-duration
0
100
30.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?
A model of wasp control by a potential gene drive in the upper South Island of Aotearoa New Zealand.

This version is in an abstract 50 x 50km space.

## HOW IT WORKS
### Overview
Each 1km grid cell location in the model study area has an associated population carrying **`capacity`** which controls the population dynamics of the area. The maximum possible carrying capacity is set by the **max-capacity-per-sq-km** control. In this abstract space, the capacity is decreases linearly from west to east.

### Population dynamics
At any given moment the the number of wasp nests (i.e. queens) in a grid cell is contained in the patch list variable **pops** which records respectively the number of *wild* (W), *gene-drive modified* (G) and *sterile* (S) queens in the cell. The reproductive population is given by W + G, which in model code is

    set reproductive sum but-last pops

The mean annual reproductive rate of all cells in a given year is determined from the parameter setting **R-mean** and **R-sd** by drawing from a normal distribution.

    set R-annual random-normal R-mean R-sd

This is modified locally per patch based on the current population and capacity according to 

    set R-local (1 - mortality) + (R-annual + mortality) * (1 - pop / capacity)

where **mortality** will usually be set to 1 (since wasps are an annual species with no overlap between generations) and the boosting of R by the amount of the mortality setting ensures that **R-mean** is an expected number of surviving new queens *net* of mortality of the current generation. When **mortality** is set to 1 this formulation is equivalent to a logistic map.

The expected new population in a cell is given by

    set new-pop R-local * reproductive

Stochastic variation is optionally applied when **stochastic-repro?** is set On, using either

    set new-pop random-poisson new-pop

or

    set new-pop nbinmoial-with-mean-vmr new-pop var-mean-ratio

The former is used when **var-mean-ratio** is set to 1, while the latter is applied with any higher value. The **nbinomial-with-mean-vmr** reporter converts specified mean *m* and variance mean ratio *vmr* to the *r* and *p* parameters of the Negative Binomial according to *r = m / (vmr - 1)* and *p = 1 - (1 / vmr)*  and invokes *random-nbinomial* which converts this to an appropriate composite Gamma-Poisson mixture (see https://en.wikipedia.org/wiki/Negative_binomial_distribution#Gamma%E2%80%93Poisson_mixture).

### Genetics
The total **new-pop** *N*<sup>+</sup> is split into wild, GM and sterile sub-populations by a multinomial draw with weights given by 
    
  *p<sub>W</sub>* = *W*<sup>2</sup>
  *p<sub>G</sub>* = 2*WG*, and
  *p<sub>S</sub>* = *G*<sup>2</sup>

Note that a binomial random generator has been coded in place of a naive implementation requiring _n_ random numbers to be generated for Bin(_n_, _p_), which would work but is slow for large _n_ and low _p_.

This is also the basis for an implementation of a multinomial variate draw, which distributes a requested _n_ items among categories weighted according to the wild, GM and sterile weights calculated above. The reporter works by repeated conditional binomial draws where each draw is based on the current remaining items to be drawn, and weight of the current category relative to the total weight of all categories (including the present one), i.e.,

  *W*<sup>+</sup> ~ Bin(*n*, *p<sub>W</sub>* / (*p<sub>W</sub>* + *p<sub>G</sub>*))
  *G*<sup>+</sup> ~ Bin(*n* - *W*<sup>+</sup>, *p*<sub>G</sub>* / (1 - *p*<sub>W</sub>))
  *S*<sup>+</sup> = *N<sup>+</sup> - *W*<sup>+</sup> - *G*<sup>+</sup> 

Note that for assignment to just three categories the reporter seems to be faster than the extension based **rnd:rnd:weighted-n-of-list-with-repeats** function.

### Dispersal
New population may disperse to new locations. 

Each member of the population draws a random distance **`random-exponential d-mean`** and heading **`random 360`** and attempts to move to that location. If the location happens to have 0 **`capacity`** the dispersing population is lost. 

With low probability **`p-ldd`** the dispersal may be _long distance_ meaning that the destination location will be a randomly selected road cell, which could be anywhere on the map.

An alternative implementation based on calculation of a dispersal kernel and the **rnd:weighted-n-of-list-with-repeats** reporter has been tried, but does not appear to run as quickly as this implementation.

## CREDITS AND REFERENCES
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

square 3
false
0
Rectangle -7500403 true true 0 0 300 300

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
true
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="80"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 1 pops] of the-habitable-land</metric>
    <metric>sum [item 2 pops] of the-habitable-land</metric>
    <enumeratedValueSet variable="pop-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="var-mean-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdev-occupancy">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution-scale">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-setup">
      <value value="&quot;random-correlated&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="10"/>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stochastic-repro?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-capacity-per-sq-km">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-6"/>
      <value value="1.0E-4"/>
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colonies-per-site">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LDD">
      <value value="&quot;targetted-roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-occupancy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortality">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-kernel-method?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogeneous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="d-mean">
      <value value="0.5"/>
      <value value="2"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="1.5"/>
      <value value="2"/>
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 1 pops] of the-habitable-land</metric>
    <metric>sum [item 2 pops] of the-habitable-land</metric>
    <enumeratedValueSet variable="var-mean-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdev-occupancy">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution-scale">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-setup">
      <value value="&quot;random-correlated&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="10"/>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-sites" first="4" step="2" last="20"/>
    <enumeratedValueSet variable="proportion-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stochastic-repro?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-capacity-per-sq-km">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colonies-per-site">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LDD">
      <value value="&quot;untargetted&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-occupancy">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortality">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-kernel-method?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogeneous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="d-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-grid-releases" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 1 pops] of the-habitable-land</metric>
    <metric>sum [item 2 pops] of the-habitable-land</metric>
    <enumeratedValueSet variable="var-mean-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdev-occupancy">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution-scale">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-setup">
      <value value="&quot;random-correlated&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="30"/>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stochastic-repro?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-capacity-per-sq-km">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colonies-per-site">
      <value value="1"/>
      <value value="4"/>
      <value value="9"/>
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LDD">
      <value value="&quot;untargetted&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-occupancy">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortality">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-kernel-method?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogeneous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="d-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-releases?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-resolution">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-grid-releases-2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>total-gm</metric>
    <metric>total-sterile</metric>
    <metric>total-released</metric>
    <enumeratedValueSet variable="var-mean-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdev-occupancy">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution-scale">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-setup">
      <value value="&quot;random-correlated&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="10"/>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stochastic-repro?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-capacity-per-sq-km">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colonies-per-site">
      <value value="1"/>
      <value value="4"/>
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LDD">
      <value value="&quot;untargetted&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-occupancy">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortality">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="d-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monitor-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-releases?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-resolution">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-or-temporal">
      <value value="&quot;spatial&quot;"/>
      <value value="&quot;temporal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="program-duration">
      <value value="20"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
