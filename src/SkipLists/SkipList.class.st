"
A skiplist is a sorted data structure that allows one to search for any element in o(log n) time.

It also allows one to enumerate forward to the next element. Basically, its a tree-like algorithm, except it doesn't use trees.

The implementation here is similar to a Dictionary, in that it indexes (a subclass of) Associations. Thus, you can do    foo at: key put: value   You can also search for a key, if the key does not exist, it will report the first key greater than the search, or nil.

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
	^ super new initialize: 10
]

{ #category : 'instance creation' }
SkipList class >> new: anInteger [
	^ self maxLevel: (anInteger log: 2) ceiling
]

{ #category : 'instance creation' }
SkipList class >> new: anInteger sortBlock: aBlock [
	^ (self new: anInteger) sortBlock: aBlock
]

{ #category : 'instance creation' }
SkipList class >> newFrom: aCollection [ 
	| skipList |
	skipList := self new: aCollection size.
	skipList addAll: aCollection.
	^ skipList
]

{ #category : 'instance creation' }
SkipList class >> sortBlock: aBlock [
	^ self new sortBlock: aBlock
]

{ #category : 'adding' }
SkipList >> add: element [ 
        "Add an association or key on to the skiplist"
        ^self add: element ifPresent: [].
        
]

{ #category : 'adding' }
SkipList >> add: element ifPresent: aBlock [
        ^self at: element put: element ifPresent: aBlock.

]

{ #category : 'enumerating' }
SkipList >> associationsDo: aBlock [
        self nodesDo: [:node | aBlock value: node]
]

{ #category : 'accessing' }
SkipList >> at: element [ 
        ^self at: element ifAbsent: []
]

{ #category : 'accessing' }
SkipList >> at: element ifAbsent: aBlock [
        "Get the key if it exists, or if it doesn't exist, get the key just after it."
        | node forward |
        node := self.
        level to: 1 by: -1 do: [:i |
                        [forward := node forward: i.
                        self is: forward before: element] whileTrue: [node := forward]].
        node := node next.
        (self is: node theNodeFor: element) ifFalse: [^aBlock value].
        ^node value

]

{ #category : 'adding' }
SkipList >> at: key put: value [ 
        "Add an association or key on to the skiplist"
        ^self at: key put: value ifPresent: [].
        
]

{ #category : 'adding' }
SkipList >> at: key put: value ifPresent: aBlock [
        | node lvl s |
        node := self search: key updating: splice.
        node ifNotNil: [^ aBlock value].
        lvl := self randomLevel.
        node := SkipListNode key: key value: value level: lvl.
        level + 1 to: lvl do: [:i | splice at: i put: self].
        1 to: lvl do: [:i |
                                s := splice at: i.
                                node atForward: i put: (s forward: i).
                                s atForward: i put: node].
        numElements := numElements + 1.
        splice atAllPut: nil.
        ^ node

]

{ #category : 'private' }
SkipList >> atForward: i put: node [
	level := node
		ifNil: [pointers findLast: [:n | n notNil]]
		ifNotNil: [level max: i].
	^ pointers at: i put: node
]

{ #category : 'copying' }
SkipList >> copy [
	"Create a copy of the receiver.
	Note: It's hard to operate on skipList structure.
	Easier is to recreate a neww from scratch."
	
	"This one bugs if used with different keys and values...
	^self class newFrom: self"
	
	| copy |
	copy := self class new.
	copy sortBlock: sortBlock.
	self keysAndValuesDo: [:k :v | copy at: k put: v].
	^copy
]

{ #category : 'enumerating' }
SkipList >> do: aBlock [
        self nodesDo: [:node | aBlock value: node value]
]

{ #category : 'accessing' }
SkipList >> first [
        ^pointers first.

]

{ #category : 'private' }
SkipList >> forward: i [ 
	^ pointers at: i
]

{ #category : 'testing' }
SkipList >> includes: key [
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
SkipList >> is: node before: element [ 
        | key |
        node ifNil: [^ false].
        key := node key.
        ^ sortBlock
                ifNil: [key < element]
                ifNotNil: [(self is: key equalTo: element) ifTrue: [^ false].
                        sortBlock value: key value: element]
]

{ #category : 'element comparison' }
SkipList >> is: element1 equalTo: element2 [
	^ element1 = element2
]

{ #category : 'private' }
SkipList >> is: node theNodeFor: key [ 
        node ifNil: [^ false].
        node == self ifTrue: [^ false].
        
        ^ self is: node key equalTo: key
]

{ #category : 'testing' }
SkipList >> isEmpty [
	^ numElements = 0
]

{ #category : 'enumerating' }
SkipList >> keysAndValuesDo: aBlock [
        ^self associationsDo:[:assoc|
                aBlock value: assoc key value: assoc value].
]

{ #category : 'enumerating' }
SkipList >> keysDo: aBlock [
        self nodesDo: [:node | aBlock value: node key]
]

{ #category : 'accessing' }
SkipList >> level [
	^ level
]

{ #category : 'accessing' }
SkipList >> maxLevel [
	^ pointers size
]

{ #category : 'accessing' }
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

{ #category : 'node enumeration' }
SkipList >> nodesDo: aBlock [
	| node |
	node := pointers first.
	[node notNil]
		whileTrue:
			[aBlock value: node.
			node := node next]
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

{ #category : 'removing' }
SkipList >> remove: element [ 
	^ self remove: element ifAbsent: [self errorNotFound: element]
]

{ #category : 'removing' }
SkipList >> remove: key ifAbsent: aBlock [
        | node i s |
        "Remove and return th association containing key."
        node := self search: key updating: splice.
        node ifNil: [^ aBlock value].
        i := 1.
        [s := splice at: i.
        i <= level and: [(s forward: i) == node]]
                                whileTrue:
                                        [s atForward: i put: (node forward: i).
                                        i := i + 1].
        numElements := numElements - 1.
        splice atAllPut: nil.
        ^ node.

]

{ #category : 'removing' }
SkipList >> removeAll [
	pointers atAllPut: nil.
	splice atAllPut: nil.
	numElements := 0.
	level := 0.
]

{ #category : 'accessing' }
SkipList >> search: element [ 
        "Get the key if it exists, or if it doesn't exist, get the key just after it. If no key after it, return nil."
        | node forward |
        node := self.
        level to: 1 by: -1 do: [:i |
                        [forward := node forward: i.
                        self is: forward before: element] whileTrue: [node := forward]].
        node := node next.
        ^node
]

{ #category : 'private' }
SkipList >> search: element updating: array [
        | node forward |
        node := self.
        level to: 1 by: -1 do: [:i |
                        [forward := node forward: i.
                        self is: forward before: element] whileTrue: [node := forward].
                        "At this point: node < element <= forward"
                        array ifNotNil: [array at: i put: node]].
        node := node next.
        ^ (self is: node theNodeFor: element) ifTrue: [node]
]

{ #category : 'accessing' }
SkipList >> size [
	^ numElements
]

{ #category : 'accessing' }
SkipList >> sortBlock [
	^ sortBlock
]

{ #category : 'accessing' }
SkipList >> sortBlock: aBlock [
	sortBlock := aBlock
]
