Class {
	#name : 'BaselineOfSkipList',
	#superclass : 'BaselineOf',
	#classVars : [
		'LastVersionLoad'
	],
	#category : 'BaselineOfSkipList',
	#package : 'BaselineOfSkipList'
}

{ #category : 'baselines' }
BaselineOfSkipList >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec blessing: #baseline.
		spec
			package: 'SkipLists';
			package: #'SkipLists-Tests'.
		spec
			group: 'Core' with: #( 'SkipLists' );
			group: 'Tests' with: #( 'SkipLists' #'SkipLists-Tests' ) ]
]
