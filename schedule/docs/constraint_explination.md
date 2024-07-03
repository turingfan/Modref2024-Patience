# constraint model explanation

## Input variables

Our constraint model represents the training instance set
as a three dimensional vector, named __data__. The first dimension
represents each instance of the training set, the second dimension 
represents the algorithm used, with the third dimension containing
a length 2 vector containing first an integer encoding of the result
of the algorithm on that instance, followed by the execution time of
that algorithm on that instance.

The results are encoded as integers from 0 to 2, with 0 representing
_unsolvable_, 1 representing _solved_, and 2 representing _unknown_.

```essenceprime
$ matrix indexes
letting result be 1
letting time be 2

$ result encodings
letting unknown be 2
letting solved be 1
letting unsolvable be 0

$ training instance set
given data : matrix indexed by [ int(1..numInstances), int(1..numAlgorithms), int(1..2)] of int(0..)
```

The cutoff time (__timeLimit__) to optimise for is also required, and is passed as an integer.
As time is clearly continuous, some level of granularity is needed to encode 
time as an integer. We decided on a granularity of 0.1 seconds, as a middle ground
between the precsion of the resulting schedule and the time taken for a solver to
find said schedule.
The maximum possible PAR10 score is derrived from this time limit.

```essenceprime
given timeLimit : int(..)
letting PAR10Limit be timeLimit * 10
```

Three domains are derrived from the above variables, __INSTANCES__, representing integer encodings
of the training set instances (used to enumerate instances in the __data__ vector),
__ALGORITHMS__, the integer encoding of the alogrithms (used to enumerate algorithms 
in the __data__ vector), and __TIME_LIMIT__ the integer encoding of all possible 
maximum solving times to assign to an algorithm (including 0 for algorithms which should not be run).

```essenceprime
letting INSTANCES be domain int(1..numInstances)
letting ALGORITHMS be domain int(1..numAlgorithms)
letting TIME_LIMIT be domain int(0..timeLimit)
```

Repeated executions of an algorithm in the same schedule are modelled
through the duplication of the model's instance data in the above __data__ vector.
However, this introduces significant symmetry which can be avoided through
identifying which algorithms are duplicated. Therefore an __algorithmRef__
vector was used to encode the identity of each algorithm as an integer,
where duplicated algorithms share an integer encoding, or _reference_.

```essenceprime
given algorithmRef : matrix indexed by [ ALGORITHMS ] of ALGORITHMS
```

## Decision variables

Two vectors of decision variables are used to encode the
resulting optimal schedule. __order__ represents the order each algorithm
is executed in the resulting schedule. __timePortion__ represents the maximum 
execution time initially allocated to each algorithm (another mechanism
is used to allocate the sum of leftover times to the final algorithm).

```essenceprime
find order : matrix indexed by [ ALGORITHMS ] of ALGORITHMS
find timePortion : matrix indexed by [ ALGORITHMS ] of TIME_LIMIT
```

Two constraints are then placed on these two vectors, ensuring that
the _order_ vector contains unique elements, and that the _timePortion_
vector's sum is equal to the total _timeLimit_.

```essenceprime
allDiff(order),

timeLimit = sum(timePortion),
```

The PAR10 score for the resulting schedule is stored in an
integer decision variable __PAR10__, which is minimised using
the __minimising__ objective.

```essenceprime
find PAR10 : int(0..PAR10Limit * numAlgorithms * numInstances)
minimising PAR10
```

### Auxilliary variables for PAR10 calculation

In order to calculate the total PAR10 time for the training instance set,
we make use of four auxilliary vectors; __leftoverTime__, __hasResult__, 
__minSolvableAlgorithm__ and __executionTime__.

The __leftoverTime__ vector is two dimensional indexed by _INSTANCES_ and
_ALGORITHMS_, and represents the positive difference between an algorithm's
_timePortion_ and the acutal execution time of that algorithm, if
the _order_ of that algorithm isn't last. If the _order_ of the algorithm is
last, we set the corresponding _leftoverTime_ to 0. This therefore allows
us to later increase the _timePortion_ of the last algorithm by the sum of the
_leftoverTime_ subvector for that instance.

```essenceprime
find leftoverTime : matrix indexed by [ INSTANCES, ALGORITHMS ] of TIME_LIMIT

$ zero leftover time for timedout non-last algorithms
forAll instance : INSTANCES .
    forAll algorithm : ALGORITHMS .
        order[algorithm] < numAlgorithms /\
        data[instance, algorithm, time] > timePortion[algorithm] ->
            leftoverTime[instance, algorithm] = 0,

$ zero leftover time for last algorithms
forAll instance : INSTANCES .
    forAll algorithm : ALGORITHMS .
        order[algorithm] = numAlgorithms ->
            leftoverTime[instance, algorithm] = 0,

$ calculate leftover time for non-timedout non-last algorithms
forAll instance : INSTANCES .
    forAll algorithm : ALGORITHMS .
        order[algorithm] < numAlgorithms /\
        data[instance, algorithm, time] <= timePortion[algorithm] -> (
            leftoverTime[instance, algorithm] = 
            timePortion[algorithm] - data[instance, algorithm, time],
        )
```

The __hasResult__ vector contains a boolean value for each instance of the
training set, representing if the schedule can find a definative result
for that instance (i.e. not _unknown_). For non-last models, this equates
to if the result of that algorithm is not _unknown_ and the algorithm's
execution time is less than the _timePortion_ for that algorithm. If the
order of the algorithm is last however, the _timePortion_ must be adjusted
by the sum of the _leftoverTime_ for all algorithms in that instance.

```essenceprime
find hasResult : matrix indexed by [ INSTANCES ] of bool

$ find if the instance is solvable within the time limit
forAll instance : INSTANCES .
    hasResult[instance] = (
        (
            exists algorithm : ALGORITHMS . 
                order[algorithm] < numAlgorithms
                /\ data[instance, algorithm, result] != unknown
                /\ data[instance, algorithm, time] <= timePortion[algorithm]
        )
        \/
        (
            exists algorithm : ALGORITHMS . 
                order[algorithm] = numAlgorithms
                /\ data[instance, algorithm, result] != unknown
                /\ data[instance, algorithm, time] 
                <= timePortion[algorithm] + sum(leftoverTime[instance, ..])
        )
    ),
```

The __minSolvableAlgorithm__ vector contains the integer encoding of the
lowest _order_ algorithm which finds a certain result in less than the
allocated time. Similarly to the _hasResult_ vector, this can be split into
two cases: the last algorithm in the schedule and all other algorithms.
Should an algorithm execute last, the total time allocated must be increased
by the sum of the _leftoverTime_ vector for that instance.

The _minSolvableAlgorithm_ for an instance can now be constrainted to be an
algorithm which has a certain result in less than the allocated time, where
no other algorithm exists with the same condition and lower order. 

```essenceprime
find minSolvableAlgorithm : matrix indexed by [ INSTANCES ] of ALGORITHMS

$ find the earliest solvable algorithm for each instance
forAll instance : INSTANCES .
    hasResult[instance] -> ( $ if the instance has a certain result
        (
            exists algorithm : ALGORITHMS .
                $ algorithm isn't last
                order[algorithm] < numAlgorithms
                $ outcome is certain
                /\ data[instance, algorithm, result] != unknown 
                $ executes in less than the allocated time
                /\ data[instance, algorithm, time] <= timePortion[algorithm] 
                $ there doesn't exist another algorithm which
                /\ (!exists otherAlgorithm : ALGORITHMS . 
                    $ has a lower order
                    order[otherAlgorithm] < order[algorithm] 
                    $ outcome is certain
                    /\ data[instance, otherAlgorithm, result] != unknown 
                    $ executes in less than the allocated time
                    /\ data[instance, otherAlgorithm, time] <= timePortion[otherAlgorithm] 
                )
                /\ minSolvableAlgorithm[instance] = algorithm $ assigning the algorithm to the auxilliary variable
        )
        \/
        (
            exists algorithm : ALGORITHMS .
                $ algorithm is last
                order[algorithm] = numAlgorithms 
                $ outcome is certain
                /\ data[instance, algorithm, result] != unknown 
                $ executes in less than the allocated time
                /\ data[instance, algorithm, time] <= timePortion[algorithm] + sum(leftoverTime[instance, ..]) 
                $ there doesn't exist another algorithm which
                /\ (!exists otherAlgorithm : ALGORITHMS . 
                    $ has a lower order
                    order[otherAlgorithm] < order[algorithm] 
                    $ outcome is certain
                    /\ data[instance, otherAlgorithm, result] != unknown 
                    $ executes in less than the allocated time
                    /\ data[instance, otherAlgorithm, time] <= timePortion[otherAlgorithm] 
                )
                /\ minSolvableAlgorithm[instance] = algorithm $ assigning the algorithm to the auxilliary variable
        )
    ),
```

The __executionTime__ one dimensional vector contains the PAR10 scores for each
instance, calculated using the three auxilliary variables above. This is again
split into two cases, if the schedule can find a certain result for an instance
or not. In the latter case, the PAR10 score for that instance is the maximum possible
PAR10 score (_PAR10Limit_). 
In the former case, the total instance execution time is the sum of the time each
algorithm with an order earlier than the _minSolvableAlgorithm_ for that instance
executed for. The lastmost algorithm is again separated here due to the
possibility for it to exceed the _timePortion_ variable.

Boolean expressions were used to "filter" elements from the `sum` constraint.
These are equated to 1 if true, and 0 if false.

The total _PAR10_ score can then be constrained to the sum of the
_executionTime_ vector.

```essenceprime
find executionTime : matrix indexed by [ INSTANCES ] of int(0..PAR10Limit)

$ find the PAR10 times for each instance
forAll instance : INSTANCES .
    !hasResult[instance] -> (
        executionTime[instance] = PAR10Limit
    ),
forall instance : INSTANCES .
    hasResult[instance] -> (
        executionTime[instance] = (sum algorithm : ALGORITHMS .
            (order[algorithm] <= order[minSolvableAlgorithm[instance]])
            *
            (order[algorithm] < numAlgorithms)
            *
            min(timePortion[algorithm], data[instance, algorithm, time])
        )
        +
        (
            (order[numAlgorithms] < order[minSolvableAlgorithm[instance]])
            *
            data[instance, numAlgorithms, time]
        )
    ),

$ channelling execution times into objective variable
PAR10 = sum(executionTime),
```

## timePortion granularity

In order to reduce the search time of the resulting model, we decided
to limit the granularity of the _timePortion_ splits. Up to 10 seconds,
the granularity of _timePortion_ remains at 0.1 seconds. Between
10 and 60 seconds, we decrease the granularity to 1 second. For larger
than 60 second time portions, we decrease the granularity to 10 seconds.
To ensure the sum of the _timePortion_ vector is still equal to the
_timeLimit_, the last model to execute maintains a 0.1 second granularity.

```essenceprime
$ pseudo-logarithmic split times
forAll algorithm : ALGORITHMS .
    algorithm != maxNonZeroAlgorithm /\
    timePortion[algorithm] != 0 -> 
        (
            (
                timePortion[algorithm] >= 100
                /\ timePortion[algorithm] < 600
                ->
                    (
                        timePortion[algorithm] % 10 = 0
                    )
            )
            /\
            (
                timePortion[algorithm] >= 600
                ->
                    (
                        timePortion[algorithm] % 100 = 0
                    )
            )
        ),

$ max non zero algorithm
exists algorithm : ALGORITHMS .
    maxNonZeroAlgorithm = algorithm
    /\ timePortion[algorithm] != 0
    /\ (!exists otherAlgorithm : ALGORITHMS .
        timePortion[otherAlgorithm] != 0
        /\ order[otherAlgorithm] > order[algorithm]
    ),

$ set timeout of last algorithm
timePortion[maxNonZeroAlgorithm] = timeLimit - (
    sum otherAlgorithm : ALGORITHMS .
        (otherAlgorithm != maxNonZeroAlgorithm) *
        timePortion[otherAlgorithm]
),
```

## symmetry breaking

We placed two constraints on algorithms with a shared _algorithmRef_
value, which both constrain the order of duplicate algorithms to break symmetries.
Firstly, if there exists a duplicate algorithm with a larger integer
encoding with 0 _timePortion_, all duplicate algorithms with a smaller integer
encoding must also have a 0 _timePortion_.
Secondly, if there exists a duplicate algorithm with a larger order, the _timePortion_
of the later duplicate must be larger than that of the first.

We also eliminated some of the symmetry for algorithms with a 
_timePortion_ of 0 (algorithms which don't take place in the
schedule) by ensuring their order was before algorithms with a non-zero
_timePortion_.

Although symmetry remains in the order of the 0 _timePortion_ algorithms,
we found that solver search increased when this order was constrained.
We also disregard duplicate algorithms from this symmetry breaking, as
those symmetries are handled by the above constraints.

```essenceprime
$ symmetry breaking for 0 time algorithms
forAll algorithm : ALGORITHMS .
    timePortion[algorithm] = 0 -> (
        !(exists otherAlgorithm : ALGORITHMS .
            otherAlgorithm != algorithm
            /\ algorithmRef[otherAlgorithm] != algorithmRef[algorithm]
            /\ order[otherAlgorithm] < order[algorithm]
            /\ timePortion[otherAlgorithm] > 0
        )
    ),
```
