globals
[
  rank1    ;;Shop whose %-filled is maximum
  rank2    ;;Shop whose %-filled is medium
  rank3    ;;Shop whose %-filled is minimum

  qual_1   ;;Shop whose quality is maximum
  qual_2   ;;Shop whose quality is medium
  qual_3   ;;Shop whose quality is minimum

  temp     ;;
  days
  flag     ;;flag used to count the No. of poor and rich
  prev     ;;stores the top shop in previous tick(15 days)
  hungry   ;;No. of customers not assigned to any shop (Everyday)

  capacity1     ;;capacity of shop1
  capacity2     ;;capacity of shop2
  capacity3     ;;capacity of shop3
]

;;Creating breeds
breed [management1 shop1]
breed [management2 shop2]
breed [management3 shop3]
breed [customers cust]

;;Properties of each breed
;;sums - Total no. of customers for each shop after 15 days
;;per - percenatge filled of each shop after 15 days
;;ct_fill - No. of times a shop's %-filled is greater than 60%
;;no_cust - No. of customers for each shop on a particular day
;;budget - budget of each customer

management1-own [fund qual price capacity sums per ct_fill no_cust]
management2-own [fund qual price capacity sums per ct_fill no_cust]
management3-own [fund qual price capacity sums per ct_fill no_cust]
customers-own [ budget ]
;;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to setup
  clear-all

  ask patches
  [
    set pcolor black
    if pxcor = -6
    [
      set pcolor grey
    ]
    if pxcor = 6
    [
      set pcolor grey
    ]
  ]

  set-default-shape management1 "house"
  set-default-shape management2 "house"
  set-default-shape management3 "house"
  set-default-shape customers "person"

  ;;Shop1
  create-management1 1
  [
    set color blue
    set size 5
    setxy -13 -13
    set fund if1
    set qual random-tween-inclusive shop1_qual_min shop1_qual_max
    set label "Shop1"
    set price 4 * qual
  ]

  ;;Shop2
  create-management2 1
  [
    set color green
    set size 5
    setxy 0 -13
    set fund if2
    set qual random-tween-inclusive shop2_qual_min shop2_qual_max
    set label "Shop2"
    set price 4 * qual
  ]

  ;;Shop3
  create-management3 1
  [
    set color red
    set size 5
    setxy 13 -13
    set fund if3
    set qual random-tween-inclusive shop3_qual_min shop3_qual_max
    set label "Shop3"
    set price 4 * qual
  ]

  ;;Customers
  create-customers no_of_cust
  [
     set color black
     set size 1.2
     setxy random-xcor random-tween-inclusive -12 16
  ]

  ;;
  set_ranks

  set flag 0

  ask customers
  [
    set flag flag + 1
    setxy random-xcor random-tween-inclusive -10 16
    ifelse flag <= ( 0.7 *  no_of_cust)
    [
      set budget  random-tween-inclusive 6 30
      set color red
    ]
    [
      set budget random-tween-inclusive 31 90
      set color white
    ]
    set label round budget
  ]


  ask management1
  [
    set capacity round ( fund / qual )
    set capacity1 capacity
  ]

  ask management2
  [
    set capacity round ( fund / qual )
    set capacity2 capacity
  ]

  ask management3
  [
    set capacity round ( fund / qual )
    set capacity3 capacity
  ]

  set temp 1
  set prev rank1
  reset-ticks

end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to go

  set days days + 1

  set hungry 0

  no_cust_reset

  if days mod 90 = 0
  [
    create-customers (1.02 * no_of_cust ) - no_of_cust
    [
      set size 1.2
      setxy random-xcor random-ycor
    ]
    set no_of_cust round ( no_of_cust * 1.02 )
  ]


  customer_allotment_1

  wait 0.5

  budget-assign

  percent-fill

  if days mod 15 = 0
  [
    strategy
  ]

  capacity-assign

  tick
end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to no_cust_reset
  ask management1
  [
    set no_cust 0
  ]

  ask management2
  [
    set no_cust 0
  ]

  ask management3
  [
    set no_cust 0
  ]
end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to percent-fill

  ask management1
  [
    set sums ( sums + round ( fund / qual ) - capacity )
  ]

  ask management2
  [
    set sums ( sums + round ( fund / qual ) - capacity )
  ]

  ask management3
  [
    set sums ( sums + round ( fund / qual ) - capacity )
  ]
end
;;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to customer_allotment_1
  ask customers
  [
    ifelse budget >= [price] of qual_1
    [
      ifelse [capacity] of qual_1 > 0
      [
        ask qual_1
        [
          set capacity capacity - 1
          set no_cust  no_cust + 1
        ]
        setxy random-tween-inclusive  ([pxcor] of qual_1 - 2 ) ([pxcor] of qual_1 + 2)  random-tween-inclusive -10 16
        set budget budget - [price] of qual_1
      ]
      [
        customer_allotment_2
      ]
    ]
    [
      customer_allotment_2
    ]
  ]
end


to customer_allotment_2
  ifelse budget >= [price] of qual_2
  [
    ifelse [capacity] of qual_2 > 0
    [
      ask qual_2
      [
        set capacity capacity - 1
        set no_cust  no_cust + 1
      ]
      setxy random-tween-inclusive  ([pxcor] of qual_2 - 2 ) ([pxcor] of qual_2 + 2)  random-tween-inclusive -10 16
      set budget budget - [price] of qual_2
    ]
    [
      customer_allotment_3
    ]
  ]
  [
    customer_allotment_3
  ]
end


to customer_allotment_3

  ifelse budget >= [price] of qual_3
  [
    ifelse [capacity] of qual_3 > 0
    [
      ask qual_3
      [
        set capacity capacity - 1
        set no_cust  no_cust + 1
      ]
      setxy random-tween-inclusive  ([pxcor] of qual_3 - 2 ) ([pxcor] of qual_3 + 2)  random-tween-inclusive -10 16
      set budget budget - [price] of qual_3
    ]
    [
      set hungry hungry + 1
      setxy one-of [-6 6 ]  random-tween-inclusive -10 16
    ]
  ]
  [
    set hungry hungry + 1
    setxy one-of [-6 6 ]  random-tween-inclusive -10 16
  ]
end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to strategy

  ask management1
  [
    set per ( sums * 100 ) / ( 15 * round ( fund / qual ))
    ifelse per > 60
    [
      set ct_fill ct_fill + 1
    ]
    [
      set ct_fill 0
    ]
    set sums 0
  ]

  ask management2
  [
    set per ( sums * 100 ) / ( 15 * round ( fund / qual ))
    ifelse  per > 60
    [
      set ct_fill ct_fill + 1
    ]
    [
      set ct_fill 0
    ]
    set sums 0
  ]

  ask management3
  [
    set per ( sums * 100 ) / ( 15 * round ( fund / qual ))
    ifelse per > 60
    [
      set ct_fill ct_fill + 1
    ]
    [
      set ct_fill 0
    ]
    set sums 0
  ]


  if temp >= 3
  [
    ask rank1
    [
      if ct_fill >= 3
      [
        set price (price * (1 + (rank1_price / 100 )) )
        if  (qual *  (1 + (rank1_qual / 100 )) ) > 0
        [
          set qual (qual *  (1 + (rank1_price / 100 )) )
        ]
        set  ct_fill 0
        set temp 1
       ]
     ]
   ]

  ask rank2
  [
    if (price * (1 + (rank2_price / 100 )) ) > 0
    [
      set price (price * (1 + (rank2_price / 100 )) )
    ]
    if (qual * (1 + (rank2_qual / 100 )) ) < 10
    [
      set qual ( qual * (1 + (rank2_price / 100 )) )
    ]
  ]

  ask rank3
  [
    if (price * (1 + (rank3_price / 100 )) ) > 0
    [
      set price (price * (1 + (rank3_price / 100 )) )
    ]
    if (qual * (1 + (rank3_qual / 100 )) ) < 10
    [
      set qual ( qual * (1 + (rank3_qual / 100 )) )
    ]
  ]


  set_ranks

  ifelse prev = rank1
  [
    set temp temp + 1
  ]
  [
    set temp 1
    set prev rank1
  ]

 funds-change

end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to-report random-tween-inclusive [ a b ]
    report a + random (b - a)
end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to set_ranks

   ifelse [per] of one-of management1 >= [per] of one-of management2
   [
     ifelse [per] of one-of management1 >= [per] of one-of management3
     [
       set rank1 one-of management1
       ifelse [per] of one-of management2 >= [per] of one-of management3
       [
         set rank2 one-of management2
         set rank3 one-of management3
       ]
       [
         set rank2 one-of management3
         set rank3 one-of management2
       ]
     ]
     [
       set rank1 one-of management3
       set rank2 one-of management1
       set rank3 one-of management2
     ]
   ]
   [
     ifelse [per] of one-of management2 >= [per] of one-of management3
     [
       set rank1 one-of management2
       ifelse [per] of one-of management1 >= [per] of one-of management3
       [
         set rank2 one-of management1
         set rank3 one-of management3
       ]
       [
         set rank2 one-of management3
         set rank3 one-of management1
       ]
     ]
     [
       set rank1 one-of management3
       set rank2 one-of management2
       set rank3 one-of management1
     ]
   ]


   ifelse [qual] of one-of management1 >= [qual] of one-of management2
   [
     ifelse [qual] of one-of management1 >= [qual] of one-of management3
     [
       set qual_1 one-of management1
       ifelse [qual] of one-of management2 >= [qual] of one-of management3
       [
         set qual_2 one-of management2
         set qual_3 one-of management3
       ]
       [
         set qual_2 one-of management3
         set qual_3 one-of management2
       ]
     ]
     [
       set qual_1 one-of management3
       set qual_2 one-of management1
       set qual_3 one-of management2
     ]
   ]
   [
     ifelse [qual] of one-of management2 >= [qual] of one-of management3
     [
       set qual_1 one-of management2
       ifelse [qual] of one-of management1 >= [qual] of one-of management3
       [
         set qual_2 one-of management1
         set qual_3 one-of management3
       ]
       [
         set qual_2 one-of management3
         set qual_3 one-of management1
       ]
     ]
     [
       set qual_1 one-of management3
       set qual_2 one-of management2
       set qual_3 one-of management1
     ]
   ]
end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to funds-change

  ask management1
  [
    ifelse per < 60
    [
      set fund (fund * 0.9 )
    ]
    [
      set fund (fund * 1.2 )
    ]
  ]

  ask management2
  [
    ifelse per < 60
    [
      set fund (fund * 0.9 )
    ]
    [
      set fund (fund * 1.2 )
    ]
  ]

  ask management3
  [
    ifelse per < 60
    [
      set fund (fund * 0.9 )
    ]
    [
      set fund (fund * 1.2 )
    ]
  ]
end
;;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to budget-assign

  set flag 0
  ask customers
  [
    set flag flag + 1
    setxy random-xcor random-tween-inclusive -10 16
    ifelse flag <= ( 0.7 *  no_of_cust)
    [
      set budget budget + random-tween-inclusive poor_min poor_max
      set color red
    ]
    [
      set budget budget + random-tween-inclusive rich_min rich_max
      set color white
    ]
  ]

  ask customers
  [
    set label round budget
  ]
end
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to capacity-assign
 ask management1
 [
   set capacity round ( fund / qual )
   if capacity + capacity2 + capacity3 >= no_of_cust
   [
     set capacity capacity1
   ]
   set capacity1 capacity
 ]

 ask management2
 [
   set capacity round ( fund / qual )
   if capacity1 + capacity + capacity3 >= no_of_cust
   [
     set capacity capacity2
   ]
   set capacity2 capacity
 ]

 ask management3
 [
   set capacity round ( fund / qual )
   if capacity1 + capacity2 + capacity >= no_of_cust
   [
     set capacity capacity3
   ]
   set capacity3 capacity
 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
298
10
737
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
300
476
392
509
if1
if1
0
1000
169
1
1
NIL
HORIZONTAL

SLIDER
395
476
487
509
if2
if2
0
1000
273
1
1
NIL
HORIZONTAL

SLIDER
490
476
582
509
if3
if3
0
1000
182
1
1
NIL
HORIZONTAL

BUTTON
18
16
91
49
setup
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

BUTTON
105
16
168
49
go
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
15
67
72
112
rank1
rank1
17
1
11

MONITOR
75
67
132
112
rank2
rank2
17
1
11

MONITOR
135
68
192
113
rank3
rank3
17
1
11

CHOOSER
774
64
866
109
shop2_qual_min
shop2_qual_min
1 2 3 4 5 6 7 8 9 10
5

CHOOSER
868
64
960
109
shop2_qual_max
shop2_qual_max
1 2 3 4 5 6 7 8 9 10
8

CHOOSER
868
19
960
64
shop1_qual_max
shop1_qual_max
1 2 3 4 5 6 7 8 9 10
7

CHOOSER
773
18
865
63
shop1_qual_min
shop1_qual_min
1 2 3 4 5 6 7 8 9 10
3

CHOOSER
868
111
960
156
shop3_qual_max
shop3_qual_max
1 2 3 4 5 6 7 8 9 10
9

CHOOSER
774
111
866
156
shop3_qual_min
shop3_qual_min
1 2 3 4 5 6 7 8 9 10
0

SLIDER
616
474
737
507
no_of_cust
no_of_cust
0
1000
275
1
1
NIL
HORIZONTAL

MONITOR
7
271
64
316
qual1
[qual] of management1
17
1
11

MONITOR
68
272
125
317
qual2
[qual] of management2
17
1
11

MONITOR
129
272
186
317
qual3
[qual] of management3
17
1
11

MONITOR
6
322
63
367
cap1
capacity1
17
1
11

MONITOR
67
322
124
367
cap2
capacity2
17
1
11

MONITOR
129
322
186
367
cap3
capacity3
17
1
11

MONITOR
217
13
274
58
NIL
days
17
1
11

MONITOR
6
370
63
415
per1
[per] of management1
17
1
11

MONITOR
129
373
186
418
per3
[per] of management3
17
1
11

MONITOR
67
372
124
417
per2
[per] of management2
17
1
11

MONITOR
6
420
63
465
price1
[price] of management1
17
1
11

MONITOR
67
421
124
466
price2
[price] of management2
17
1
11

MONITOR
128
422
185
467
price3
[price] of management3
17
1
11

PLOT
768
161
1015
310
Cost of plate
Days
Cost
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Shop1" 1.0 0 -13345367 true "" "plot [price] of one-of management1"
"Shop2" 1.0 0 -13840069 true "" "plot [price] of one-of management2"
"Shop3" 1.0 0 -2674135 true "" "plot [price] of one-of management3"

PLOT
769
314
1016
464
Funds change
Days
Funds
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Shop1" 1.0 0 -13345367 true "" "plot [fund] of one-of management1"
"Shop2" 1.0 0 -13840069 true "" "plot [fund] of one-of management2"
"Shop3" 1.0 0 -2674135 true "" "plot [fund] of one-of management3"

PLOT
1021
160
1279
310
% Capacity filled
Days
% filled
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"Shop1" 1.0 0 -13345367 true "" "plot [per] of one-of management1"
"Shop2" 1.0 0 -13840069 true "" "plot [per] of one-of management2"
"Shop3" 1.0 0 -2674135 true "" "plot [per] of one-of management3"

PLOT
1022
314
1282
464
Quality of food
Days
Quality
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Shop1" 1.0 0 -14070903 true "" "plot [qual] of one-of management1"
"Shop2" 1.0 0 -13840069 true "" "plot [qual] of one-of management2"
"Shop3" 1.0 0 -2674135 true "" "plot [qual] of one-of management3"

PLOT
965
10
1278
157
No. of Customers
Days
Customers
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Shop1" 1.0 0 -13345367 true "" "plot [no_cust] of one-of management1"
"shop2" 1.0 0 -14439633 true "" "plot [no_cust] of one-of management2"
"shop3" 1.0 0 -2674135 true "" "plot [no_cust] of one-of management3"

MONITOR
212
466
277
511
no_food
hungry
17
1
11

MONITOR
7
467
61
512
Eat1
[no_cust] of management1
17
1
11

MONITOR
66
469
123
514
Eat2
[no_cust] of management2
17
1
11

MONITOR
128
469
185
514
Eat3
[no_cust] of management3
17
1
11

SLIDER
16
117
123
150
rank1_price
rank1_price
0
30
6
1
1
NIL
HORIZONTAL

SLIDER
130
120
237
153
rank1_qual
rank1_qual
-15
0
-3
1
1
NIL
HORIZONTAL

SLIDER
16
154
129
187
rank2_price
rank2_price
-30
0
-3
1
1
NIL
HORIZONTAL

SLIDER
131
154
238
187
rank2_qual
rank2_qual
0
30
3
1
1
NIL
HORIZONTAL

SLIDER
16
188
126
221
rank3_price
rank3_price
-30
0
-3
1
1
NIL
HORIZONTAL

SLIDER
130
189
239
222
rank3_qual
rank3_qual
0
30
3
1
1
NIL
HORIZONTAL

SLIDER
188
273
294
306
poor_min
poor_min
3
7
6
1
1
NIL
HORIZONTAL

SLIDER
189
309
294
342
poor_max
poor_max
8
14
11
1
1
NIL
HORIZONTAL

SLIDER
190
344
295
377
rich_min
rich_min
15
21
16
1
1
NIL
HORIZONTAL

SLIDER
189
379
296
412
rich_max
rich_max
22
30
27
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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
false
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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
