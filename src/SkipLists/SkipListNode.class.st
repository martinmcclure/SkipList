"
This is a skiplist node. It can be treated as an association that allows a 'next' operator to go to the next node in the skiplist.


"
Class {
	#name : 'SkipListNode',
	#superclass : 'Association',
	#instVars : [
		'pointers'
	],
	#category : 'SkipLists',
	#package : 'SkipLists'
}

{ #category : 'instance creation' }
SkipListNode class >> key: key value: value level: maxLevel [ 
        ^ (super key: key value: value) initialize: maxLevel
]

{ #category : 'instance creation' }
SkipListNode class >> new: maxLevel [
	^ super new initialize: maxLevel
]

{ #category : 'instance creation' }
SkipListNode class >> on: element level: maxLevel [ 
        ^ self key: element value: element level: maxLevel

]

{ #category : 'instance creation' }
SkipListNode class >> tailOfLevel: n [
	^ self on: nil level: n
]

{ #category : 'accessing' }
SkipListNode >> atForward: i put: node [
	^ pointers at: i put: node
]

{ #category : 'accessing' }
SkipListNode >> forward: i [ 
	^ pointers at: i
]

{ #category : 'initialization' }
SkipListNode >> initialize: maxLevel [
	pointers := Array new: maxLevel
]

{ #category : 'accessing' }
SkipListNode >> level [
	^ pointers size
]

{ #category : 'accessing' }
SkipListNode >> next [
	^ pointers first
]

{ #category : 'accessing' }
SkipListNode >> printOn: aStream [
        | first |
        aStream
                nextPut: $[.
        super printOn: aStream.
        aStream
                nextPutAll: ']-->('.
        first := true.
        pointers do: [:node |
                first ifTrue: [first := false] ifFalse: [aStream space].
                node ifNil: [aStream nextPutAll: '*'] 
                ifNotNil: [node printOn: aStream]].
        aStream nextPut: $)

]
