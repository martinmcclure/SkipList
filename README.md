# SkipList
A skip list is a data structure with space and time performance similar to a balanced binary tree, but simpler to implement.

This Smalltalk implementation can be used as a sorted set, or as a dictionary sorted by key.
The sort can be the natural sorting of the keys (using the results of sending #<, etc) or by providing a sort block as in SortedCollection.

This implementation is based on the one by Hernán Morales Durand, and differs from the original primarily in these ways:
* The API more closely matches Set and Dictionary protocol.
* The searching protocol has been expanded.
* More tests have been added.