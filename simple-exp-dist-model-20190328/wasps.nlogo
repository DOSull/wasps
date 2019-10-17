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

  ;; distances of successful dispersals
  distances

  ;; history of populations
  pop-history
  wild-history
  gm-history
]

patches-own [
  capacity
  pop
  pops
  next-pops
  init-pop
  init-pops
  r-loc
  road?
]
@#$#@#$#@
GRAPHICS-WINDOW
205
10
631
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
r-mean
r-mean
1.0
4
3.0
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
129
386
197
431
NIL
total-pop
0
1
11

PLOT
638
283
954
473
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
26
228
198
261
p-ldd
p-ldd
0
0.001
1.0E-5
0.00001
1
NIL
HORIZONTAL

MONITOR
93
436
198
481
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
r-sd
r-sd
0
0.25
0.25
0.001
1
NIL
HORIZONTAL

SLIDER
25
135
197
168
lambda-1
lambda-1
0.01
10
0.5
0.01
1
NIL
HORIZONTAL

MONITOR
45
486
199
531
mean-occupancy-rate
mean-occupancy-rate
3
1
11

SLIDER
687
156
806
189
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
776
195
948
228
init-prop-gm
init-prop-gm
0
0.5
0.01
0.01
1
NIL
HORIZONTAL

BUTTON
818
235
950
269
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
810
156
950
189
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
670
236
812
270
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

PLOT
639
480
953
670
Dispersal distances
distance
ln frequency
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"d" 1.0 0 -16777216 true "" ""

SLIDER
843
17
950
50
seed
seed
0
1000
500.0
1
1
NIL
HORIZONTAL

SWITCH
810
55
952
88
use-seed?
use-seed?
1
1
-1000

SLIDER
731
92
835
125
init-mean-occ
init-mean-occ
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
837
92
952
125
init-sd-occ
init-sd-occ
0
0.5
0.1
0.001
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

A model of dispersal processes in a fragmented landscape.

## HOW IT WORKS

See O'Sullivan and Perry, 2009. A discrete space model for continuous  
space dispersal processes. Ecological Informatics, 4(2), 57-68.

This paper explains the operation of the dispersal process aspect of the model.

## HOW TO USE IT

## THINGS TO NOTICE

## THINGS TO TRY

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## CREDITS AND REFERENCES

O'Sullivan, D. and G. L. W. Perry. 2009. A discrete space model for continuous  
space dispersal processes. Ecological Informatics, 4(2), 57-68.
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
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="base-r1sd0-iter5-pldd0" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>min-d</metric>
    <metric>max-d</metric>
    <steppedValueSet variable="landscape-seed" first="1001" step="1" last="1030"/>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="setup-iter-1_23_seeds" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>max-d</metric>
    <metric>min-d</metric>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="landscape-seed" first="1028" step="1" last="1050"/>
  </experiment>
  <experiment name="setup-iter-0_23_seeds" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>max-d</metric>
    <metric>min-d</metric>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="landscape-seed" first="1028" step="1" last="1050"/>
  </experiment>
  <experiment name="setup-iter-2_23_seeds" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>max-d</metric>
    <metric>min-d</metric>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="landscape-seed" first="1028" step="1" last="1050"/>
  </experiment>
  <experiment name="setup-iter-4_23_seeds" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>max-d</metric>
    <metric>min-d</metric>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="landscape-seed" first="1028" step="1" last="1050"/>
  </experiment>
  <experiment name="setup-iter-8_23_seeds" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>max-d</metric>
    <metric>min-d</metric>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="landscape-seed" first="1028" step="1" last="1050"/>
  </experiment>
  <experiment name="setup-iter-16_23_seeds" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>max-d</metric>
    <metric>min-d</metric>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="landscape-seed" first="1028" step="1" last="1050"/>
  </experiment>
  <experiment name="setup-iter-50_seeds_noLDD" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total-pop</metric>
    <metric>total-extent</metric>
    <metric>mean-d</metric>
    <metric>max-d</metric>
    <metric>min-d</metric>
    <enumeratedValueSet variable="ensure-equal-areas?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-quality">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda-2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="H">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-ldd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="levels">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-quality">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="0.72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-iter">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-weeds?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eff-lambda">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="landscape-seed" first="1001" step="1" last="1050"/>
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