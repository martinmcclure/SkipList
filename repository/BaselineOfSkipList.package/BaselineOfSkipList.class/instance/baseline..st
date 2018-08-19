baselines
baseline: spec
	<baseline>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'github://hernanmd/SkipList/repository/'.
		spec 
			package: 'SkipLists';
			package: #'SkipLists-Tests'.
		spec 
			group: 'Core' with: #('SkipLists' );
			group: 'Tests' with: #('SkipLists' #'SkipLists-Tests' ). ].
