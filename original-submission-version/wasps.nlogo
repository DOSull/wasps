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

__includes [ "setup.nls" "main.nls" "display.nls"
  "dispersal.nls" "reproduction.nls"
  "profile.nls" ]

extensions [ palette vid gis profiler array ]

breed [ vizs viz ]
breed [ roads road ]

globals [
  ;; population related
  num-pops
  total-pop
  capacities
  mean-occupancy-rate

  ;; dispersal related
  total-extent
  prop-occupied

  mean-d
  min-d
  max-d
  source

  ;; colour palettes for display
  pals

  ;; subsets of the patches
  the-land
  the-sea
  the-roads
  the-habitable-land
  potential-release-sites
  monitoring-area

  ;; distances of successful dispersals
  ;; distances

  ;; history of populations
;  pop-history
;  wild-history
;  gm-history
]

patches-own [
  capacity
  pop
  pops
  next-pops
  init-pop
  init-pops
  lambda-loc
  road?
  history
]
@#$#@#$#@
GRAPHICS-WINDOW
207
10
633
671
-1
-1
2.0
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
208
0
325
1
1
1
ticks
30.0

BUTTON
646
13
709
46
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
27
10
199
43
lambda-mean
lambda-mean
1.0
4
2.5
0.01
1
NIL
HORIZONTAL

BUTTON
646
50
709
83
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
646
86
709
119
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
17
480
85
525
NIL
total-pop
0
1
11

PLOT
638
283
954
669
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
25
141
197
174
p-ldd
p-ldd
0
0.001
1.0E-4
0.00001
1
NIL
HORIZONTAL

MONITOR
91
480
196
525
NIL
prop-occupied
3
1
11

SLIDER
26
47
198
80
lambda-sd
lambda-sd
0
0.25
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
26
99
198
132
d-mean
d-mean
0.01
10
5.0
0.01
1
NIL
HORIZONTAL

MONITOR
43
530
197
575
mean-occupancy-rate
mean-occupancy-rate
3
1
11

SLIDER
654
199
773
232
show-pop
show-pop
0
num-pops
0.0
1
1
NIL
HORIZONTAL

SLIDER
681
164
820
197
base-prop-gm
base-prop-gm
0
0.5
0.0
0.01
1
NIL
HORIZONTAL

BUTTON
788
241
920
275
NIL
color-patches\n
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
777
199
917
232
show-pop?
show-pop?
0
1
-1000

BUTTON
717
13
823
47
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
640
242
782
276
toggle-roads
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
844
15
951
48
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
811
53
953
86
use-seed?
use-seed?
0
1
-1000

SLIDER
823
126
952
159
init-mean-occ
init-mean-occ
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
823
162
951
195
init-sd-occ
init-sd-occ
0
0.5
0.0
0.001
1
NIL
HORIZONTAL

CHOOSER
20
189
196
234
scenario
scenario
"base plus release sites" "release sites only" "base only"
0

SLIDER
18
277
190
310
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
22
240
172
270
Parameters for \"release sites\" scenario
12
0.0
1

TEXTBOX
750
122
820
152
Base pop initialisation
12
0.0
1

SLIDER
18
315
190
348
wasps-per-site
wasps-per-site
0
1000
500.0
1
1
NIL
HORIZONTAL

SLIDER
18
353
190
386
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
15
393
190
426
release-type
release-type
0
1
1.0
1
1
NIL
HORIZONTAL

SWITCH
6
640
201
673
track-monitoring-area?
track-monitoring-area?
0
1
-1000

BUTTON
68
599
193
633
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

SLIDER
17
431
190
464
periodicity
periodicity
0
10
1.0
1
1
NIL
HORIZONTAL

SWITCH
813
90
951
123
homogenous?
homogenous?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?
A model of wasp control by a potential gene drive in the upper South Island of Aotearoa New Zealand, as reported in 

* Lester PJ, D O'Sullivan and GLW Perry. (In press). Gene drives for invasive pest
control: extinction is unlikely, with suppression levels dependent on local dispersal
and intrinsic growth rates. _Biology Letters_

## HOW IT WORKS
### Overview
Each 1km grid cell location in the model study area has an associated population capacity `capacity` which controls the population dynamics of the area. 

### Population dynamics
At any given moment the the number of wasp nests (i.e. queens) in a grid cell is contained in the list `pops` which records respectively the number of wild, gene-drive modified and sterile queens in the cell. The reproductive population is given by 

    set reproductive sum but-last pops ;; i.e. item 0 + item 1

The local growth rate of the cell `lambda-loc` is determined from the parameter setting `lambda-mean` and `lambda-sd` each year by draw from a normal distribution.

    set lamdba-loc random-normal lambda-mean lambda-sd

These are combined to determine the total population of queens in the next generation according to 

    set new-pop random-poisson lambda-loc * reproductive * (capacity - sum pops) / capacity

The total `new-pop` is then allocated to wild, GM and sterile sub-populations by repeated draws from a Binomial distribution. This is implemented by code in **`reproduction.nls`** which has been commented in detail. Note that a binomial random generator has been coded in place of a naive implementation requiring _n_ random numbers to be generated for Bin(_n_, _p_), which would work but is slow for large _n_ and low _p_.

### Dispersal
New population may disperse to new locations. Each member of the population draws a random distance `random-exponential d-mean` and heading `random 360` and attempts to move to that location. If the location happens to have 0 `capacity` the dispersing population is lost. 

With low probability `p-ldd` the dispersal may be _long distance_ meaning that the destination location will be a randomly selected road cell, which could be anywhere on the map.

## CREDITS AND REFERENCES

Lester PJ, D O'Sullivan and GLW Perry. (In press). Gene drives for invasive pest
control: extinction is unlikely, with suppression levels dependent on local dispersal
and intrinsic growth rates. _Biology Letters_
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
NetLogo 6.1.0
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
  <experiment name="CONTROL-EXPERIMENT-RELEASE-AND-FORGET" repetitions="1" runMetricsEveryStep="true">
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
      <value value="0"/>
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
