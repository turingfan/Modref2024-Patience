# Tweaking the optimisation problem

One issue with this approach is the inclusion of 
incomplete algorithms. If an incomplete algorithm's 
execution time is less than the cutoff time for 
that algorithm with an inconclusive result for 
that instance, the total cutoff time for that 
instance is reduced by the difference between that
algorithm's maximum execution time and the actual 
execution time. This could result in the last 
algorithm terminating before a solution is found, 
but with the total schedule execution time being 
less than the sum of the cutoff times. As the 
naive schedules outlined above always use all of 
the execution time allocated, this complicates 
the fair comparison of these naive schedules to 
those found by the constraint based approach. To 
resolve this issue, we allocate the _leftover time_
(the positive difference between the maximum 
execution time of an algorithm and the actual 
execution time of that algorithm when inconclusive) 
is allocated to the last algorithm in the schedule 
for that instance.
