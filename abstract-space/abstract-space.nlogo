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
  "patch-distances.nls"  ;; measurement of patch distances recognising they are areas not points
  "profile.nls"          ;; profilers for some parts of the model during development
]

extensions [
  palette                ;; Brewer colour palettes
  profiler               ;; profiling
  rnd                    ;; weighted random draws from lists and agentsets
  vid                    ;; video recording
;  gis                    ;; GIS data

;; ----------------
;; OD matrix method
  matrix
;  array
;; ----------------
]

breed [ vizs viz ]       ;; to visualize population mix wild (red) vs GM (blue) across space
breed [ roads road ]     ;; to visualize roads (and make it easy to turn them on/off

globals [
  R-annual               ;; this year's mean R value
  num-subpops            ;; the number of subpopulations (3 in the wasps model)
  total-pop              ;; total population across the landscape
  mean-occupancy-rate    ;; the mean population as a proportion of capacity

  ;; dispersal related
  total-extent           ;; the total number of patches with any wasps present
  prop-occupied          ;; the proportion of all habitable patches with any wasps present

  kernel-offsets         ;; list of [dx dy] values for the dispersal kernel
  kernel-weights         ;; list of relative weights for kernel offsets (ordered per the offsets)
  kernel                 ;; the list [kernel-offsets kernel-weights]

  pals                   ;; colour palettes for display in the order wild, gm, sterile, total

  ;; subsets of the patches
  the-land               ;; all non-sea patches
  the-sea                ;; all sea patches
  the-roads              ;; all patches with a road present
  the-habitable-land     ;; all patches with capacity > 0
  monitoring-area        ;; a subset of patches used to record time series data for model exploration
  central-p

;; ----------------
;; OD matrix method
;  patch-list
;  pathways
;; ----------------
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
  road?                  ;; if a road is present
  history                ;; a list recording population history for a patch in the monitoring area
  my-kernel              ;; a local copy of the dispersal kernel (which removes non-land patches from the base kernel

;; ----------------
;; OD matrix method
;  id
;; ----------------
]
@#$#@#$#@
GRAPHICS-WINDOW
198
8
614
425
-1
-1
8.0
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
50
0
50
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
R-mean
R-mean
1.0
4
1.1
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
429
613
641
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
"dying" 1.0 0 -13840069 true "" ""

SLIDER
13
548
185
581
p-ldd
p-ldd
0
0.001
0.01
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
16
473
188
506
d-mean
d-mean
0.01
10
0.5
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
1.0
1
1
NIL
HORIZONTAL

SLIDER
988
325
1159
358
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
0
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
ask roads [set hidden? not hidden?]
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
1.0
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
1
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
0.5
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
874
170
1050
215
scenario
scenario
"base plus release sites" "release sites only" "base only"
0

SLIDER
1123
32
1295
65
number-of-sites
number-of-sites
0
50
20.0
1
1
NIL
HORIZONTAL

TEXTBOX
1119
10
1424
28
Parameters for any \"release sites\" scenario
12
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
1123
70
1294
103
colonies-per-site
colonies-per-site
0
1000
1.0
1
1
NIL
HORIZONTAL

SLIDER
1123
108
1295
141
percentile-selector
percentile-selector
0
1
0.95
0.01
1
NIL
HORIZONTAL

SLIDER
1124
221
1296
254
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
1124
166
1297
199
periodicity
periodicity
0
10
0.0
1
1
NIL
HORIZONTAL

SWITCH
988
285
1159
318
homogeneous?
homogeneous?
1
1
-1000

SWITCH
982
485
1174
518
use-kernel-method?
use-kernel-method?
1
1
-1000

MONITOR
1111
610
1200
655
kernel-area
length kernel
0
1
11

SWITCH
984
413
1176
446
use-logistic-map?
use-logistic-map?
0
1
-1000

SWITCH
13
260
183
293
stochastic-repro?
stochastic-repro?
1
1
-1000

SWITCH
821
503
931
536
debug?
debug?
1
1
-1000

SLIDER
13
390
185
423
var-mean-ratio
var-mean-ratio
1
5
2.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
1298
29
1364
57
how many \nlocations
11
0.0
1

TEXTBOX
1297
67
1404
95
colonies' worth of \nwasps per site
11
0.0
1

TEXTBOX
1298
102
1427
144
where in the habitat\ndistribution to select \nrelease sites
11
0.0
1

TEXTBOX
1300
170
1468
220
how often to release wasps: \n0 =  never (or only at t0)\nn = every n years
11
0.0
1

TEXTBOX
1300
223
1463
279
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
500
5000
500.0
10
1
NIL
HORIZONTAL

TEXTBOX
1161
328
1288
356
initialise with GM wasps everyhere
11
0.0
1

TEXTBOX
1163
288
1280
316
initialise with same capacity everywhere
11
0.0
1

TEXTBOX
984
266
1134
284
Special cases
12
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
14
116
186
149
R-sd
R-sd
0
0.5
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
13
171
185
204
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
169
111
Surviving offspring per queen net of mortality - for logistic map M = 1
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
19
296
188
380
Exp(N) each generation is R * pop. Stochastic option will vary this according to a Poisson distribution (vmr = 1) or a Negative Binomial (vmr > 1)
11
0.0
1

TEXTBOX
7
225
157
255
Stochastic variation in reproduction
12
0.0
1

TEXTBOX
10
451
160
469
Dispersal
14
0.0
1

TEXTBOX
17
510
167
538
Mean distance (exponentially distributed)
11
0.0
1

TEXTBOX
17
583
191
639
Probability of long distance dispersal to a randomly select road location
11
0.0
1

TEXTBOX
824
407
974
425
Internal controls
14
0.0
1

TEXTBOX
834
428
984
484
These will likely become internal global variables at some point - provided for experimentation
11
0.0
1

TEXTBOX
990
451
1140
469
Almost always a yes!
11
0.0
1

TEXTBOX
825
542
975
598
When we remember, debug messages can be shown in the command centre
11
0.0
1

TEXTBOX
987
524
1341
604
Experimental! Does not reliably produce expected mean distances even when generated by simulation. Discrete kernels are a complex problem see, e.g., Chipperfield, J. D. et al. (2011) ‘On the approximation of continuous dispersal kernels in discrete-space models’, Methods in Ecology and Evolution, 2(6), pp. 668–681.\n
11
15.0
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
19
153
169
171
Annual variability in R
11
0.0
1

BUTTON
986
618
1105
652
NIL
show-kernel
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1182
475
1291
520
kernel-mean-d
get-kernel-mean-d
4
1
11

SWITCH
1341
398
1446
431
roads?
roads?
1
1
-1000

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

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="INVASION-EXPERIMENT" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <exitCondition>prop-occupied = 0 or prop-occupied &gt;= 0.95</exitCondition>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.5"/>
      <value value="2"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="30"/>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.01"/>
      <value value="1.0E-4"/>
      <value value="1.0E-6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1.5"/>
      <value value="2"/>
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="gc-19-base" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 0 pops] of the-land</metric>
    <metric>sum [item 1 pops] of the-land</metric>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-5"/>
      <value value="1.0E-4"/>
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-prop-gm">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.075"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base only&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="gc-19-collapse" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 0 pops] of the-land</metric>
    <metric>sum [item 1 pops] of the-land</metric>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-prop-gm">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base only&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="gc-19-introductions" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>save-monitor</final>
    <timeLimit steps="150"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 0 pops] of the-land</metric>
    <metric>sum [item 1 pops] of the-land</metric>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-prop-gm">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <exitCondition>prop-occupied = 0.95 or total-pop = 0</exitCondition>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <enumeratedValueSet variable="r-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.5"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0"/>
      <value value="1.0E-5"/>
      <value value="1.0E-4"/>
      <value value="3.0E-4"/>
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="30"/>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;release sites only&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-nozero" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10"/>
    <exitCondition>total-pop = 0 or prop-occupied &gt; 0.95 or ticks &gt; 100</exitCondition>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <steppedValueSet variable="lambda-1" first="0.5" step="0.5" last="3"/>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="30"/>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-4"/>
      <value value="0.001"/>
      <value value="0.01"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="r-mean" first="1.6" step="0.2" last="2.4"/>
    <enumeratedValueSet variable="periodicity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.075"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;release sites only&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="time-series-by-lambda-pldd-71-100-t250" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 1 pops] of the-habitable-land</metric>
    <metric>sum [item 2 pops] of the-habitable-land</metric>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.5"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="71" step="1" last="80"/>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.01"/>
      <value value="0.001"/>
      <value value="1.0E-4"/>
      <value value="1.0E-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="CONTROL-EXPERIMENT" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 1 pops] of the-habitable-land</metric>
    <metric>sum [item 2 pops] of the-habitable-land</metric>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.5"/>
      <value value="2"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="30"/>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.01"/>
      <value value="1.0E-4"/>
      <value value="1.0E-6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1.5"/>
      <value value="2"/>
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="MONITOR" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>save-monitor</final>
    <timeLimit steps="250"/>
    <enumeratedValueSet variable="lambda-1">
      <value value="0.5"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-sd-occ">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogenous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="track-monitoring-area?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-prop-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1.5"/>
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wasps-per-site">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-mean-occ">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="CONTROL-EXPERIMENT-RELEASE-AND-FORGET-ABSTRACT-SPACE" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>total-pop</metric>
    <metric>prop-occupied</metric>
    <metric>sum [item 1 pops] of the-habitable-land</metric>
    <metric>sum [item 2 pops] of the-habitable-land</metric>
    <enumeratedValueSet variable="d-mean">
      <value value="0.5"/>
      <value value="2"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="30"/>
    <enumeratedValueSet variable="stdev-occupancy">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentile-selector">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homogeneous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sites">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.01"/>
      <value value="1.0E-4"/>
      <value value="1.0E-6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-gm">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="release-type">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-pop?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="R-mean">
      <value value="1.1"/>
      <value value="1.3"/>
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colonies-per-site">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-occupancy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="R-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortality">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-logistic-map?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-kernel-method?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;base plus release sites&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stochastic-repro?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="var-mean-ratio">
      <value value="2"/>
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
