"
A SkipListTest is tests basic functionality of SkipList

Instance Variables: none

"
Class {
	#name : 'SkipListTest',
	#superclass : 'ClassTestCase',
	#instVars : [
		's',
		'd',
		'sortBlock'
	],
	#category : 'SkipLists-Tests',
	#package : 'SkipLists-Tests'
}

{ #category : 'testing' }
SkipListTest class >> mustTestCoverage [

	^ true
]

{ #category : 'coverage' }
SkipListTest >> classToBeTested [

	^ SkipList
]

{ #category : 'support' }
SkipListTest >> keyRange [
	"The range of keys used in most tests"

	^ self minKey to: self maxKey
]

{ #category : 'support' }
SkipListTest >> makeSkipList [
	"Create a random SkipList, and a matching Dictionary for use in a test."

	| size |
	size := (10 to: 100) atRandom.
	s := SkipList new: size sortBlock: sortBlock.
	d := Dictionary new: size.
	size timesRepeat: [
		| key value |
		[
		key := self keyRange atRandom.
		d includesKey: key ] whileTrue.
		value := key printString.
		d at: key put: value.
		s at: key put: value ]
]

{ #category : 'support' }
SkipListTest >> maxKey [
	"The largest key used in most tests"

	^ 10000
]

{ #category : 'support' }
SkipListTest >> minKey [
	"The smallest key used in most tests"

	^ -10000
]

{ #category : 'support' }
SkipListTest >> randomKeysDo: aBlock [
	"Evaluate aBlock many times with random keys."

	self maxKey timesRepeat: [ aBlock value: self keyRange atRandom ]
]

{ #category : 'support' }
SkipListTest >> selectorsToBeIgnored [

	| c |
	c := self classToBeTested.
	^ (c selectorsInProtocol: #private)
	  , (c selectorsInProtocol: #'private auditing')
	  , (c selectorsInProtocol: #initialization)
]

{ #category : 'support' }
SkipListTest >> setUp [

	super setUp.
	self makeSkipList.
	self assert: s sortBlock identicalTo: nil.
	s audit
]

{ #category : 'support' }
SkipListTest >> tearDown [

	s audit.
	super tearDown
]

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

{ #category : 'tests' }
SkipListTest >> testAssociationAt [

	d keysAndValuesDo: [ :k :v |
		self assert: (s associationAt: k) equals: k -> v ].

	self randomKeysDo: [ :k |
		(d includesKey: k)
			ifTrue: [
			self assert: (s associationAt: k) equals: k -> k printString ]
			ifFalse: [ self should: [ s associationAt: k ] raise: KeyNotFound ] ]
]

{ #category : 'tests' }
SkipListTest >> testAssociationAtIfAbsent [

	d keysAndValuesDo: [ :k :v |
		self
			assert: (s associationAt: k ifAbsent: [ 'nevermore' ])
			equals: k -> v ].

	self randomKeysDo: [ :k |
		(d includesKey: k)
			ifTrue: [
				self
					assert: (s associationAt: k ifAbsent: [ 'evermore' ])
					equals: k -> k printString ]
			ifFalse: [
				self
					assert: (s associationAt: k ifAbsent: [ 'clevermore' ])
					equals: 'clevermore' ] ]
]

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
SkipListTest >> testCoverage [

	super testCoverage
]

{ #category : 'tests' }
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

{ #category : 'tests' }
SkipListTest >> testDo [

	| count prev |
	count := 0.
	prev := SmallInteger minVal.
	s do: [ :val |
		| valAsNumber |
		self assert: (val isKindOf: String).
		valAsNumber := val asNumber.
		self assert: prev < valAsNumber.
		count := count + 1.
		prev := valAsNumber ].
	self assert: count equals: d size
]

{ #category : 'tests' }
SkipListTest >> testEmpty [

	| esk count |
	esk := SkipList new.
	esk audit.
	self
		assert: esk isEmpty;
		assert: esk size equals: 0;
		should: [ esk first ] raise: CollectionIsEmpty;
		should: [ esk firstAssociation ] raise: CollectionIsEmpty;
		should: [ esk at: '3' ] raise: KeyNotFound;
		should: [ esk associationAt: 'foo' ] raise: KeyNotFound;
		should: [ esk associationAtOrAfter: 'bar' ] raise: KeyNotFound;
		should: [ esk remove: 'bat' ] raise: KeyNotFound;
		should: [ esk removeKey: 'boo' ] raise: KeyNotFound;
		assert: (esk at: 'third' ifAbsent: [ 4 ]) equals: 4;
		assert: (esk associationAt: 'baz' ifAbsent: [ 42 ]) equals: 42;
		assert: (esk associationAtOrAfter: 12 ifAbsent: [ 24 ]) equals: 24;
		assert: (esk associationBefore: 10 ifAbsent: [ 2 ]) equals: 2;
		assert: (esk remove: -1 ifAbsent: [ 'who' ]) equals: 'who';
		assert: (esk removeKey: 0 ifAbsent: [ 'no' ]) equals: 'no'.


	count := 0.
	esk associationsDo: [ :a | count := count + 1 ].
	self assert: count equals: 0.
	esk keysAndValuesDo: [ :k :v | count := count + 1 ].
	self assert: count equals: 0.
	esk keysDo: [ :k | count := count + 1 ].
	self assert: count equals: 0.

	"Emptiness-related messages on a non-empty SkipList"
	esk at: 1 put: 'one'.
	self
		assert: esk size equals: 1;
		deny: esk isEmpty.
	esk audit
]

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
SkipListTest >> testIncludesKey [

	d keysDo: [ :k | self assert: (s includesKey: k) ].

	self randomKeysDo: [ :k |
		self assert: (s includesKey: k) equals: (d includesKey: k) ]
]

{ #category : 'tests' }
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
	self assert: skip first equals: node1 value.
	self assert: (skip at: 2) equals: node2 value
]

{ #category : 'tests' }
SkipListTest >> testNew_ [

	| sk |
	-100 to: 2 do: [ :i |
		sk := SkipList new: i.
		self assert: sk maxLevel equals: 1 ].

	sk := SkipList new: 3.
	self assert: sk maxLevel equals: 2.

	sk := SkipList new: 512.
	self assert: sk maxLevel equals: 9.

	sk := SkipList new: 513.
	self assert: sk maxLevel equals: 10
]

{ #category : 'tests' }
SkipListTest >> testPrinting [ 

	| sk | 
	sk := SkipList new.
	self assert: sk printString equals: 'a SkipList()'.
	sk := SkipList new: 1.
	self assert: sk printString equals: 'a SkipList()'.
	sk at: 432 put: 'no?'.
	self assert: sk printString equals: 'a SkipList(432->''no?'')'.
	sk add: 234.
	self assert: sk printString equals: 'a SkipList(234, 432->''no?'')'.
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

{ #category : 'tests' }
SkipListTest >> testRemove [
	"tests size after removing element"

	"self run:#testRemove"
	| sk |
	sk := SkipList new.
	sk add: 1.
	self assert: sk size equals: 1.
	self should: [ sk remove: 2 ] raise: KeyNotFound.
	sk remove: 1.
	self assert: sk size equals: 0
]

{ #category : 'tests' }
SkipListTest >> testRemoveAll [

	self
		deny: s isEmpty;
		assert: s size equals: d size.
	s removeAll.
	self
		assert: s isEmpty;
		assert: s size equals: 0.
	s do: [ :each | self fail: 'do: body evaluated on an empty collection' ]
]

{ #category : 'tests' }
SkipListTest >> testSortBlock [
	sortBlock := [ :a :b | a > b ].
	self should: [ s sortBlock: sortBlock ] raise: Error.
	self makeSkipList.
	self assert: s sortBlock equals: sortBlock.
	s audit
]
