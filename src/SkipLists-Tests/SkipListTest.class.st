"
A SkipListTest is tests basic functionality of SkipList

Instance Variables: none

"
Class {
	#name : 'SkipListTest',
	#superclass : 'ClassTestCase',
	#category : 'SkipLists-Tests',
	#package : 'SkipLists-Tests'
}

{ #category : 'implementationTests' }
SkipListTest >> testAdd [
	"tests size after adding element"

	"self run:#testAdd"

	| s |
	s := SkipList new.
	s add: 1.
	self
		assert: s size equals: 1;
		assert: (s at: 1) equals: 1
]

{ #category : 'implementationTests' }
SkipListTest >> testAddIfPresent [
	"adds an already existing element. Decides to add another one in the
	ifPresent block"

	| s |
	s := SkipList new.
	s add: 1.
	s add: 1 ifPresent: [ :node |
		self assert: node value equals: 1.
		s add: 2 ].
	self assert: s size equals: 2
]

{ #category : 'public' }
SkipListTest >> testAt [
	"self run: #testAt"

	"self debug: #testAt"

	| sk |
	sk := SkipList new.
	self should: [ sk at: 100 ] raise: KeyNotFound.
	sk at: 11 put: '111111'.
	sk at: 3 put: '3333'.
	sk at: 7 put: '77777'.
	sk at: 3 put: '666'.
	self assert: (sk at: 7) equals: '77777'.
	self assert: (sk includesKey: 7).
	self assert: (sk at: 3) equals: '666'.
	self assert: (sk includesKey: 3).
	self assert: sk size equals: 3.
	self should: [ sk at: 100 ] raise: KeyNotFound.
]

{ #category : 'public' }
SkipListTest >> testAtPutAlreadyPresent [
	"self run: #testAtPutAlreadyPresent"

	"self debug: #testAtPutAlreadyPresent"

	| sk |
	sk := SkipList new.
	sk at: 11 put: '111111'.
	sk at: 3 put: '3333'.
	sk at: 7 put: '77777'.
	sk at: 3 put: '666'.

	self assert: (sk at: 7) equals: '77777'.
	self assert: (sk includesKey: 7).

	self assert: (sk at: 3) equals: '666'.

	self assert: (sk includesKey: 3).
	self assert: sk size equals: 3
]

{ #category : 'public' }
SkipListTest >> testCopy [
	"This is a non regression test for http://bugs.squeak.org/view.php?id=6778"

	| original copy |
	original := SkipList new.
	original at: 3 put: '3333'.
	copy := original copy.
	copy remove: 3.
	self
		assert: (original includesKey: 3)
		description: 'changing the copy should not change the original'
]

{ #category : 'public' }
SkipListTest >> testCreation [
	"self run: #testCreation"

	"self debug: #testCreation"

	| sk |
	sk := SkipList new.
	sk at: 11 put: '111111'.
	sk at: 3 put: '3333'.
	sk at: 7 put: '77777'.
	self assert: (sk at: 7) = '77777'.
	self assert: (sk includesKey: 7)
]

{ #category : 'public' }
SkipListTest >> testIfAbsent [
	"self run: #testIfAbsent"

	"self debug: #testIfAbsent"

	| sk temp |
	sk := SkipList new.
	sk at: 11 put: '111111'.
	sk at: 3 put: '3333'.
	sk at: 7 put: '77777'.
	sk add: 7 ifPresent: [ :node |
		self assert: node value equals: '77777'.
		sk at: 8 put: '88' ].
	temp := sk at: 9 ifAbsent: [ sk at: 8 ].
	self assert: temp = '88'
]

{ #category : 'public' }
SkipListTest >> testIfPresent [
	"self run: #testIfPresent"

	"self debug: #testIfPresent"

	| sk |
	sk := SkipList new.
	sk at: 11 put: '111111'.
	sk at: 3 put: '3333'.
	sk at: 7 put: '77777'.
	sk add: 7 ifPresent: [ :node |
		self assert: node value equals: '77777'.
		sk at: 8 put: '88' ].
	self assert: (sk at: 7) equals: '77777'.
	self assert: (sk at: 8) equals: '88'
]

{ #category : 'public' }
SkipListTest >> testIsEqualTo [
	"self run: #testIsEqualTo"
	"self debug: #testIsEqualTo"

	| sk sk2 |
	sk := SkipList new.
	sk2 := SkipList new.
	sk at: 11 put: '111111'.
	sk at: 3 put: '3333'.
	sk at: 7 put: '77777'.
	sk at: 9 put: '3333'.
	
	sk2 at: 3 put: '3333'.
	sk2 at: 5 put: '3333'.
	self assert: (sk is: (sk at: 3) equalTo: (sk at: 9)).
	self assert: (sk is: (sk at: 3) equalTo: (sk2 at: 3)).
	self assert: (sk is: (sk at: 3) equalTo: (sk2 at: 5))
	
	
	

	
]

{ #category : 'implementationTests' }
SkipListTest >> testMaxLevel [
	"No node should have a level greater than the skiplist maxLevel"
	"self run: #testMaxLevel"
	| s |
	s := SkipList new.
	s add: 12.
	s add: 53.
	s add: 14.
	s
		nodesDo: [:n | 
			      self
   					assert: n level <= s maxLevel]
]

{ #category : 'implementationTests' }
SkipListTest >> testNavigation [
	"self run: #testNavigation"

	| node1 node2 node3 node4 skip |
	node1 := SkipListNode key: 1 value: 3 level: 1.
	node2 := SkipListNode key: 2 value: 7 level: 2.
	node3 := SkipListNode key: 3 value: 11 level: 1.
	node4 := SkipListNode key: 4 value: 23 level: 2.
	node1 atForward: 1 put: node2.
	node2 atForward: 1 put: node3.
	node2 atForward: 2 put: node4.
	node4 atForward: 1 put: nil.
	skip := SkipList new.
	skip atForward: 1 put: node1.
	skip atForward: 2 put: node2.
	skip instVarNamed: #numElements put: 2.
	self assert: skip first = node1 value.
	self assert: (skip at: 2) = node2 value
]

{ #category : 'implementationTests' }
SkipListTest >> testRandomLevel [
	"a randomLevel should not be greater than maxLevel"
	"self run: #testRandomLevel"
	| s |
	s := SkipList new.
	s maxLevel: 5.
	self assert: s randomLevel <= 5
]

{ #category : 'public' }
SkipListTest >> testRemove [
	"tests size after removing element"
	"self run:#testRemove"
	
	| s |
	s := SkipList new.
	s add: 1.
	self assert: s size = 1.
	self
		should: [s remove: 2]
		raise: Exception.
	s remove: 1.
	self assert: s size = 0

]
