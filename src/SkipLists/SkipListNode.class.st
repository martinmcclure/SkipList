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
SkipListNode class >> key: key value: value level: level [ 
        ^ (super key: key value: value) initialize: level
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
SkipListNode >> initialize: level [
	pointers := Array new: level
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

{ #category : 'accessing' }
SkipListNode >> printShortOn: aStream [

	key == value
		ifTrue: [ aStream << key printString ]
		ifFalse: [ super printOn: aStream ]
]

{ #category : 'private' }
SkipListNode >> species [
	"To compare equality with Associations"

	^ Association
]
