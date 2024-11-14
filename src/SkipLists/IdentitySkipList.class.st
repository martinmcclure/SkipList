"
Like a SkipList, except that elements are compared with #== instead of #= .

See the comment of IdentitySet for more information.

"
Class {
	#name : 'IdentitySkipList',
	#superclass : 'SkipList',
	#category : 'SkipLists',
	#package : 'SkipLists'
}

{ #category : 'element comparison' }
IdentitySkipList >> is: element1 equalTo: element2 [
	^ element1 == element2
]
