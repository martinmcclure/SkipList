"
Like a SkipList, except that elements are compared with #== instead of #= .

See the comment of IdentitySet for more information.

Like SkipList, the elements are sorted. The ordering of equal but non-identical keys is arbitrary.
"
Class {
	#name : 'IdentitySkipList',
	#superclass : 'SkipList',
	#category : 'SkipLists',
	#package : 'SkipLists'
}

{ #category : 'private auditing' }
IdentitySkipList >> auditSortingOfKey: prevKey withSubsequentKey: thisKey [

	^ (sortBlock
		   ifNil: [ prevKey < thisKey ]
		   ifNotNil: [ sortBlock value: prevKey value: thisKey ]) ifFalse: [
		  prevKey = thisKey ifFalse: [
			  self error: 'Found two out-of-order nodes' ] ]
]

{ #category : 'element comparison' }
IdentitySkipList >> is: element1 equalTo: element2 [
	^ element1 == element2
]
