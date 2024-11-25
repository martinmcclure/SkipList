"
A skiplist is a sorted data structure that allows one to search for any element in o(log n) time.

It also allows one to enumerate forward to the next element. Basically, its a tree-like algorithm, except it doesn't use trees.

This implementation can be used like a sorted Dictionary (see the dictionary api category), or like a sorted Set (see the ""set api"" category). The ""common api"" category applies to both kinds of use.
The Set api is implemented by storing (a subclass of) Association for each entry, with the key and value identical.

The collection is sorted by key. If no sortBlock is set, the natural ordering of the keys is used, comparing using #< and #=. If a sort block is set, it is used for inequality comparison, but #= is still used for equality tests, so the sort block must be consistent with the keys' response to #-.
  
Enumeraion is in sorted order. 

Besides searching for a key using equality (e. g. #at:) you can search using a key that is not present, and get the result that corresponds the next lower or higher key. See #associationBefore: and similar messages.

"
Class {
	#name : 'SkipList',
	#superclass : 'Collection',
	#instVars : [
		'sortBlock',
		'pointers',
		'numElements',
		'level',
		'splice'
	],
	#classVars : [
		'Rand'
	],
	#category : 'SkipLists',
	#package : 'SkipLists'
}

{ #category : 'instance creation' }
SkipList class >> maxLevel: maxLevel [
	"
	SkipList maxLevel: 5
	"
	^ super new initialize: maxLevel
]

{ #category : 'instance creation' }
SkipList class >> maxLevel: anInteger sortBlock: aBlock [
	^ (self maxLevel: anInteger) sortBlock: aBlock
]

{ #category : 'instance creation' }
SkipList class >> new [
	"
	SkipList new
	"

	^ self maxLevel: 10
]

{ #category : 'instance creation' }
SkipList class >> new: anInteger [

	| n |
	n := anInteger max: 2.
	^ self maxLevel: (n log: 2) ceiling
]

{ #category : 'instance creation' }
SkipList class >> new: anInteger sortBlock: aBlock [
	^ (self new: anInteger) sortBlock: aBlock
]

{ #category : 'instance creation' }
SkipList class >> newFrom: aCollection [
	"Create and answer a set-like SkipList that contains the contents of the collection.
	Duplicate (equal, or identical for my subclass) elements in aCollection will result in a 
	single element in the new SkipList. Do not depend on which duplicate element is retained."

	| skipList |
	skipList := self new: aCollection size.
	skipList addAll: aCollection.
	^ skipList
]

{ #category : 'instance creation' }
SkipList class >> sortBlock: aBlock [
	^ self new sortBlock: aBlock
]

{ #category : 'set api' }
SkipList >> add: aKey [
	"If aKey is not present, add the node (aKey -> aKey)."

	self add: aKey ifPresent: [ :node |  ].
	^ aKey
]

{ #category : 'set api' }
SkipList >> add: aKey ifPresent: aBlock [
	"If aKey is not present, add the node (aKey -> aKey).
	If a node with key of aKey is already present, evaluate aBlock with that node as the argument."

	^ self at: aKey put: aKey ifPresent: aBlock
]

{ #category : 'dictionary api' }
SkipList >> associationAt: aKey [

	^ self associationAt: aKey ifAbsent: [ self errorKeyNotFound: aKey ]
]

{ #category : 'dictionary api' }
SkipList >> associationAt: aKey ifAbsent: aBlock [
	"Answer the node for the key. If it doesn't exist, evaluate aBlock"

	| node |
	node := self associationAtOrAfter: aKey ifAbsent: [ ^ aBlock value ].
	(self is: node theNodeFor: aKey) ifFalse: [ ^ aBlock value ].
	^ node
]

{ #category : 'dictionary searching' }
SkipList >> associationAtOrAfter: aKey [
	"Answer the first node with a key >= aKey"

	^ self
		  associationAtOrAfter: aKey
		  ifAbsent: [ self errorKeyNotFound: aKey ]
]

{ #category : 'dictionary searching' }
SkipList >> associationAtOrAfter: aKey ifAbsent: aBlock [
	"Answer the first node with a key >= aKey.
	If none, answer the result of evaluating aBlock"

	| node |
	node := self searchAtOrAfter: aKey updating: nil.
	node ifNil: [ ^ aBlock value ].
	^ node
]

{ #category : 'dictionary searching' }
SkipList >> associationAtOrAfter: aKey ifPresent: presentBlock [
	"Find my first node with a key >= aKey.
	If no such node, answer nil. Otherwise,
	answer the result of evaluating nilary or unary 
	presentBlock with that node as its argument."

	| node |
	node := self searchAtOrAfter: aKey updating: nil.
	^ node ifNotNil: [ presentBlock cull: node ]
]

{ #category : 'dictionary searching' }
SkipList >> associationAtOrAfter: aKey ifPresent: presentBlock ifAbsent: absentBlock [
	"Find my first node with a key >= aKey.
	If no such node, answer the result of evaluating absentBlock. 
	Otherwise, answer the result of evaluating nilary or unary 
	presentBlock with that node as its argument."

	self associationAtOrAfter: aKey ifPresent: [ :node | ^ node ].
	^ absentBlock value
]

{ #category : 'dictionary searching' }
SkipList >> associationAtOrBefore: aKey ifAbsent: aBlock [
	"Answer the last entry whose key <= aKey"

	| node |
	node := self searchAtOrBefore: aKey updating: nil.
	node == self ifTrue: [ ^ aBlock value ].
	^ node
]

{ #category : 'dictionary searching' }
SkipList >> associationAtOrBefore: aKey ifPresent: presentBlock [
	"Answer the result of evaluating presentBlock with
	an argument of my last node whose key <= aKey.
	If no such node, answer nil.
	presentBlock may be nilary or unary."

	| node |
	node := self searchAtOrBefore: aKey updating: nil.
	node == self ifFalse: [ ^ presentBlock cull: node ].
	^ nil
]

{ #category : 'dictionary searching' }
SkipList >> associationAtOrBefore: aKey ifPresent: presentBlock ifAbsent: absentBlock [
	"Answer the result of evaluating present block with
	an argument of my last node whose key <= aKey.
	If no such node, answer the result of evaluating absentBlock.
	presentBlock may be nilary or unary, absentBlock must be nilary."

	self
		associationAtOrBefore: aKey
		ifPresent: [ :node | ^ presentBlock cull: node ].
	^ absentBlock value
]

{ #category : 'dictionary searching' }
SkipList >> associationBefore: aKey ifAbsent: aBlock [
	"Answer the last entry whose key < aKey"

	| node |
	node := self searchBefore: aKey updating: nil.
	node == self ifTrue: [ ^ aBlock value ].
	^ node
]

{ #category : 'dictionary searching' }
SkipList >> associationBefore: aKey ifPresent: presentBlock [
	"Answer the result of evaluating presentBlock with
	an argument of my last node whose key < aKey.
	If no such node, answer nil.
	presentBlock may be nilary or unary."

	| node |
	node := self searchBefore: aKey updating: nil.
	^ node == self ifFalse: [ presentBlock cull: node ]
]

{ #category : 'dictionary searching' }
SkipList >> associationBefore: aKey ifPresent: presentBlock ifAbsent: absentBlock [
	"Answer the result of evaluating presentBlock with
	an argument of my last node whose key < aKey.
	If no such node, answer the result of evaluating absentBlock.
	presentBlock may be nilary or unary, absentBlock must be nilary."

	self
		associationBefore: aKey
		ifPresent: [ :node | ^ presentBlock cull: node ].
	^ absentBlock value
]

{ #category : 'dictionary api' }
SkipList >> associationsDo: aBlock [

	self nodesDo: aBlock
]

{ #category : 'dictionary api' }
SkipList >> at: aKey [

	^ self at: aKey ifAbsent: [ self errorKeyNotFound: aKey ]
]

{ #category : 'dictionary api' }
SkipList >> at: aKey ifAbsent: aBlock [
	"Get the value for the key. If it doesn't exist, evaluate aBlock"

	| node forward |
	node := self.
	level to: 1 by: -1 do: [ :i |
		[
		forward := node forward: i.
		self is: forward before: aKey ] whileTrue: [ node := forward ] ].
	node := node next.
	(self is: node theNodeFor: aKey) ifFalse: [ ^ aBlock value ].
	^ node value
]

{ #category : 'dictionary api' }
SkipList >> at: key put: value [
	"Associate key with value. This adds a key, or replaces the value of an existing key."

	self at: key put: value ifPresent: [ :node | node value: value ].
	^ value
]

{ #category : 'dictionary api' }
SkipList >> at: aKey put: aValue ifPresent: aBlock [
	"If aKey is not present, add the node (aKey -> aValue) and answer aValue.
	If a node with key of aKey is already present, answer the result of 
	evaluating aBlock with that node as the argument.	"

	| node lvl s |
	node := self search: aKey updating: splice.
	node ifNotNil: [ ^ aBlock value: node ].
	lvl := self randomLevel.
	node := SkipListNode key: aKey value: aValue level: lvl.
	level + 1 to: lvl do: [ :i | splice at: i put: self ].
	1 to: lvl do: [ :i |
		s := splice at: i.
		node atForward: i put: (s forward: i).
		s atForward: i put: node ].
	numElements := numElements + 1.
	splice atAllPut: nil.
	^ aValue
]

{ #category : 'private' }
SkipList >> atForward: i put: node [
	level := node
		ifNil: [pointers findLast: [:n | n notNil]]
		ifNotNil: [level max: i].
	^ pointers at: i put: node
]

{ #category : 'auditing' }
SkipList >> audit [
	"Check my structure and signal an error if anything is amiss."

	"Invariants checked:
	* Pointers at all levels point from nodes with lower keys to higher keys (according to sort block, if any)
	* No two nodes have equal/identical keys.
	* All nodes present at a level are also present at all lower levels
	* The number of nodes at the lowest level is equal to the answer to #size
	* No nodes exist whose level is higher than the level of the SkipList.
	* All nodes are SkipListNodes"

	| nodesByLevel |
	nodesByLevel := Array new: pointers size.

	1 to: pointers size do: [ :levelNum |
	self auditLevel: levelNum into: nodesByLevel ].

	nodesByLevel first size ~= self size ifTrue: [
		self error:
			'SkipList size does not agree with number of nodes in first level' ].

	^ nodesByLevel
]

{ #category : 'private auditing' }
SkipList >> auditContiguityOfLevel: levelNum [

	(pointers at: levelNum) ifNil: [
		levelNum + 1 to: pointers size do: [ :i |
			(pointers at: i) ifNotNil: [
				self error:
					'Level ' , levelNum printString , ' is empty, but higher level '
					, i printString , ' is not empty' ] ] ]
]

{ #category : 'private auditing' }
SkipList >> auditLevel: levelNum into: nodesByLevel [

	| nodes node |
	self auditContiguityOfLevel: levelNum.
	nodes := OrderedCollection new.
	nodesByLevel at: levelNum put: nodes.
	node := pointers at: levelNum.
	[ node notNil ] whileTrue: [
		nodes add: node.
		(node isKindOf: SkipListNode) ifFalse: [
			'Node found that is not a SkipListNode' ].
		node level > level ifTrue: [
			self error:
				'Node found with level higher than the SkipList''s level' ].
		node := node forward: levelNum ].
	self auditSortingOf: nodes.
	1 to: nodes size do: [ :i |
		| thisNode |
		thisNode := nodes at: i.
		1 to: levelNum - 1 do: [ :j |
			| lowerNodes |
			lowerNodes := nodesByLevel at: j.
			(lowerNodes includes: thisNode) ifFalse: [
				self error:
					'A node in an upper level is not present in a lower level' ] ] ]
]

{ #category : 'private auditing' }
SkipList >> auditSortingOf: nodes [

	2 to: nodes size do: [ :i |
		| thisNode prevNode prevKey thisKey |
		thisNode := nodes at: i.
		thisKey := thisNode key.
		prevNode := nodes at: i - 1.
		prevKey := prevNode key.
		(self is: prevKey equalTo: thisKey) ifTrue: [
			self error: 'Found two nodes with equal/identical keys' ].
		self auditSortingOfKey: prevKey withSubsequentKey: thisKey ]
]

{ #category : 'private auditing' }
SkipList >> auditSortingOfKey: prevKey withSubsequentKey: thisKey [

	^ (sortBlock
		   ifNil: [ prevKey < thisKey ]
		   ifNotNil: [ sortBlock value: prevKey value: thisKey ]) ifFalse: [
		  self error: 'Found two out-of-order nodes' ]
]

{ #category : 'common api' }
SkipList >> copy [
	"Create a copy of the receiver.
	Note: It's hard to operate on skipList structure.
	Easier is to recreate a new one from scratch."

	| copy |
	copy := self class new.
	copy sortBlock: sortBlock.
	self keysAndValuesDo: [ :k :v | copy at: k put: v ].
	^ copy
]

{ #category : 'common api' }
SkipList >> do: aBlock [
        self nodesDo: [:node | aBlock value: node value]
]

{ #category : 'private' }
SkipList >> errorKeyNotFound: aKey [

	KeyNotFound signalFor: aKey
]

{ #category : 'set api' }
SkipList >> first [
	"Answer the value with the lowest key."

	^ self firstAssociation value
]

{ #category : 'dictionary searching' }
SkipList >> firstAssociation [
	"If I am not empty, answer my SkipListNode with the lowest key (per sortBlock, if any)."

	self
		firstAssociationIfPresent: [ :node | ^ node ]
		ifAbsent: [ self errorEmptyCollection ]
]

{ #category : 'dictionary searching' }
SkipList >> firstAssociationIfAbsent: absentBlock [
	"If I am empty, evaluate nilary or unary absentBlock. 
	Otherwise, answer my SkipListNode having the lowest key (per sortBlock, if any)."

	^ self
		  firstAssociationIfPresent: [ :node | node ]
		  ifAbsent: absentBlock
]

{ #category : 'dictionary searching' }
SkipList >> firstAssociationIfPresent: presentBlock [
	"If I am not empty, evaluate nilary or unary presentBlock with my SkipListNode having the lowest key (per sortBlock, if any)."

	^ pointers first ifNotNil: [ :node | presentBlock cull: node ]
]

{ #category : 'dictionary searching' }
SkipList >> firstAssociationIfPresent: presentBlock ifAbsent: absentBlock [
	"If I am not empty, evaluate nilary or unary presentBlock with my SkipListNode having the lowest key (per sortBlock, if any)."

	self firstAssociationIfPresent: [ :node | ^ presentBlock cull: node ].
	^ absentBlock value
]

{ #category : 'private' }
SkipList >> forward: i [ 
	^ pointers at: i
]

{ #category : 'private' }
SkipList >> includes: key [
	"Since the semantics of #includes: differ between Sets and Dictionaries,
	this dual-personality object remains neutral and does not implement it.
	Send #includesKey: instead, or make a subclass that implements this message
	the way you'd like it to work."

	self shouldNotImplement
]

{ #category : 'common api' }
SkipList >> includesKey: key [

	^ (self search: key updating: nil) notNil
]

{ #category : 'initialization' }
SkipList >> initialize: maxLevel [
	pointers := Array new: maxLevel.
	splice := Array new: maxLevel.
	numElements := 0.
	level := 0.
	Rand ifNil: [Rand := Random new]
]

{ #category : 'private' }
SkipList >> is: node before: aKey [ 
        | key |
        node ifNil: [^ false].
        key := node key.
        ^ sortBlock
                ifNil: [key < aKey]
                ifNotNil: [(self is: key equalTo: aKey) ifTrue: [^ false].
                        sortBlock value: key value: aKey]
]

{ #category : 'private' }
SkipList >> is: element1 equalTo: element2 [
	^ element1 = element2
]

{ #category : 'private' }
SkipList >> is: node theNodeFor: key [ 
        node ifNil: [^ false].
        node == self ifTrue: [^ false].
        
        ^ self is: node key equalTo: key
]

{ #category : 'common api' }
SkipList >> isEmpty [
	^ numElements = 0
]

{ #category : 'dictionary api' }
SkipList >> keysAndValuesDo: aBlock [
        ^self associationsDo:[:assoc|
                aBlock value: assoc key value: assoc value].
]

{ #category : 'dictionary api' }
SkipList >> keysDo: aBlock [
        self nodesDo: [:node | aBlock value: node key]
]

{ #category : 'common api' }
SkipList >> level [
	^ level
]

{ #category : 'common api' }
SkipList >> maxLevel [
	^ pointers size
]

{ #category : 'common api' }
SkipList >> maxLevel: n [
	| newLevel oldPointers |
	newLevel := n max: level.
	oldPointers := pointers.
	pointers := Array new: newLevel.
	splice := Array new: newLevel.
	1 to: level do: [:i | pointers at: i put: (oldPointers at: i)]

]

{ #category : 'private' }
SkipList >> next [
	^ pointers first
]

{ #category : 'private' }
SkipList >> nodesDo: aBlock [
	| node |
	node := pointers first.
	[node notNil]
		whileTrue:
			[aBlock value: node.
			node := node next]
]

{ #category : 'private' }
SkipList >> nodesDo: elementBlock separatedBy: separatorBlock [
	"Evaluate the elementBlock for all my nodes,
	and evaluate the separatorBlock between."

	| beforeFirst |
	beforeFirst := true.
	self nodesDo: [ :each |
		beforeFirst
			ifTrue: [ beforeFirst := false ]
			ifFalse: [ separatorBlock value ].
		elementBlock value: each ]
]

{ #category : 'private' }
SkipList >> printElementsOn: aStream [

	aStream nextPut: $(.
	self
		nodesDo: [ :node | node printShortOn: aStream ]
		separatedBy: [ aStream << ', ' ].
	aStream nextPut: $)
]

{ #category : 'private' }
SkipList >> randomLevel [
	| p answer max |
	p := 0.5.
	answer := 1.
	max := self maxLevel.
	[Rand next < p and: [answer < max]]
		whileTrue: [answer := answer + 1].
	^ answer
]

{ #category : 'set api' }
SkipList >> remove: aKey [

	^ self removeKey: aKey
]

{ #category : 'set api' }
SkipList >> remove: aKey ifAbsent: aBlock [

	^ self removeKey: aKey ifAbsent: aBlock
]

{ #category : 'common api' }
SkipList >> removeAll [
	pointers atAllPut: nil.
	splice atAllPut: nil.
	numElements := 0.
	level := 0.
]

{ #category : 'dictionary api' }
SkipList >> removeKey: aKey [

	^ self removeKey: aKey ifAbsent: [ self errorKeyNotFound: aKey ]
]

{ #category : 'dictionary api' }
SkipList >> removeKey: aKey ifAbsent: aBlock [
	"Remove the node with the given key and answer its value.
	If no such node, answer the result of evaluating aBlock."
	
	| node i s |
	node := self search: aKey updating: splice.
	node ifNil: [ ^ aBlock value ].
	i := 1.
	[
	s := splice at: i.
	i <= level and: [ (s forward: i) == node ] ] whileTrue: [
		s atForward: i put: (node forward: i).
		i := i + 1 ].
	numElements := numElements - 1.
	splice atAllPut: nil.
	^ node value
]

{ #category : 'private' }
SkipList >> search: aKey updating: array [
	"Answer the node whose key is equal (or identical, for IdentitySkipList) to aKey.
	Answer nil if no such node."

	| node |
	node := self searchAtOrAfter: aKey updating: array.
	^ (self is: node theNodeFor: aKey) ifTrue: [ node ]
]

{ #category : 'private' }
SkipList >> searchAtOrAfter: aKey updating: anArray [
	"Answer the first node whose key >= aKey, nil if there is no such node"

	| node |
	node := self searchBefore: aKey updating: anArray.
	^ node next
]

{ #category : 'private' }
SkipList >> searchAtOrBefore: aKey updating: anArray [
	"Answer the last node whose key <= aKey, self if there is no such node"

	| beforeNode nextNode |
	beforeNode := self searchBefore: aKey updating: anArray.
	nextNode := beforeNode next.
	^ (self is: nextNode theNodeFor: aKey)
		  ifTrue: [ nextNode ]
		  ifFalse: [ beforeNode ]
]

{ #category : 'private' }
SkipList >> searchBefore: aKey updating: anArray [
	"Answer the last node whose key < aKey, self if there is no such node"

	| node forward |
	node := self.
	level to: 1 by: -1 do: [ :i |
		[
		forward := node forward: i.
		self is: forward before: aKey ] whileTrue: [ node := forward ].
		"At this point: node < aKey <= forward, if all non-nil"
		anArray ifNotNil: [ anArray at: i put: node ] ].
	^ node
]

{ #category : 'common api' }
SkipList >> size [
	^ numElements
]

{ #category : 'common api' }
SkipList >> sortBlock [
	^ sortBlock
]

{ #category : 'common api' }
SkipList >> sortBlock: aBlock [

	self isEmpty ifFalse: [
		self error:
			'Cannot change the sort block of a SkipList with contents' ].
	sortBlock := aBlock
]
