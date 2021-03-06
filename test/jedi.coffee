"use strict"

exports.Parser =

	source:

		'external':
			input: ':external graph, Category, Seo, array_slice'
			expect: [[
				'instruction',
				[ 1, 1 ],
				'external',
				[[ 'Symbol', 'graph' ], [ 'Symbol', 'Category' ], [ 'Symbol', 'Seo' ], [ 'Symbol', 'array_slice' ]],
				[]
			]]

		'comment single line':
			input: '! comment line'
			expect: [
				['comment', [1, Number], ['comment line']]
			]
		'comment multiple lines':
			input: '''
				!	comment line 1
					comment line 2
			'''
			expect: [
				['comment', [1, Number], ['comment line 1', 'comment line 2']]
			]
		'doctype':
			input: '!html5'
			expect: [
				[
					'comment',
					[1, Number],
					['html5']
				]
			]

		'suppress single line':
			input: '-- suppress line'
			expect: [
				['suppress', [1, Number], ['suppress line']]
			]
		'suppress multiple lines':
			input: '''
				--	suppress line 1
					suppress line 2
			'''
			expect: [
				['suppress', [1, Number], ['suppress line 1', 'suppress line 2']]
			]

		'inject line':
			input: '- inject line'
			expect: [
				['inject', [1, Number], 'inject line', null, []]
			]
		'inject line with block':
			input: '''
				- inject line
					! line 1
					! line 2
			'''
			expect: [
				['inject', [1, Number], 'inject line', null, [
					['comment', [2, Number], ['line 1']]
					['comment', [3, Number], ['line 2']]
				]]
			]

		'binding of a simple symbol':
			input: '= x'
			expect: [
				['binding', [1, Number], null, ['Symbol', 'x'], []]
			]
		'binding of a list':
			input: '= [1, 2, 3]'
			expect: [
				['binding', [1, Number], null,
					['List', [['Number', 1], ['Number', 2], ['Number', 3]]],
					[]
				]
			]

		'single quot text':
			input: """
				'Hello world!
			"""
			expect: [
				['text', [1, Number], undefined, ['Hello world!']]
			]

		'single quot text no escape/interpolation':

			input: '''
				'Hello {user}!\\n
			'''

			expect: [
				['text', [1, Number], undefined, ['Hello {user}!\\n']]
			]

		'single quot multiple lines text ':
			input: """
				'	Hello world!
					foo bar baz
					rawr rawr
					super cool
			"""
			expect: [
				['text', [1, Number], undefined, ['Hello world!', 'foo bar baz', 'rawr rawr', 'super cool']]
			]

		'single quot text with single quot':
			input: """
				'	I'm ok!
			"""
			expect: [
				['text', [1, Number], undefined, ["I'm ok!"]]
			]

		'double quot text':
			input: '''
				"Hello world!
			'''
			expect: [
				['text', [1, Number], undefined, [
					[['String', 'Hello world!', 'Hello world!']]
				]]
			]
		'double quot text escape/interpolation':
			input: '''
				"Hello {user}!\\n
			'''
			expect: [
				['text', [1, Number], undefined, [
					[
						['String', 'Hello ', 'Hello ']
						['Symbol', 'user'],
						['String', '!\n', '!\\n']
					]
				]]
			]
		'double quot multiple lines text with tag':
			input: '''
				r"	Hello world!
					foo bar baz
					rawr rawr
					super cool
			'''
			expect: [
				['text', [1, Number], ['Symbol', 'r'],
					[
						[['String', 'Hello world!', 'Hello world!']]
						[['String', 'foo bar baz', 'foo bar baz']]
						[['String', 'rawr rawr', 'rawr rawr']]
						[['String', 'super cool', 'super cool']]
					]
				]
			]

		'if':
			input: '''
				:if x > y
					"{x} > {y}
			'''
			expect: [
				['instruction', [1, Number], 'if',
					['BinaryOp', '>', ['Symbol', 'x'], ['Symbol', 'y']]
					[
						['text', [2, Number], undefined, [
							[['Symbol', 'x'], ['String', ' > ', ' > '], ['Symbol', 'y']]
						]]
					]
				]
			]

		'iterate values':
			input: '''
				:for v in x
					"{v}
			'''
			expect: [
				['instruction', [1, Number], 'for',
					[[['Symbol', 'x'], ['Symbol', 'v'], undefined, undefined]]
					[['text', [2, Number], undefined, [
						[['Symbol', 'v']]
					]]]
				]
			]

		'iterate key, value pairs':
			input: '''
				:for (key, value) in x
					"{key} = {value}
			'''
			expect: [
				[
					'instruction',
					[1, Number],
					'for',
					[[
						['Symbol', 'x']
						['Symbol', 'value']
						['Symbol', 'key']
						undefined
					]],
					[
						[
							'text',
							[2, Number],
							undefined,
							[
								[
									['Symbol', 'key'],
									['String', ' = ', ' = '],
									['Symbol', 'value'],
								]
							]
						]
					]
				]
			]

		'multiple for':
			input: '''
				:for x in list1, y in list2
					"{x}, {y}
			'''
			expect: [[ 'instruction',
				[ 1, 1 ],
				'for',
				[
					[ [ 'Symbol', 'list1' ], [ 'Symbol', 'x' ], undefined, undefined ],
					[ [ 'Symbol', 'list2' ], [ 'Symbol', 'y' ], undefined, undefined ]
				],
				[[
					'text',
					[ 2, 5 ],
					undefined,
					[ [ [ 'Symbol', 'x' ], [ 'String', ', ', ', ' ], [ 'Symbol', 'y' ] ] ]
				]]
			]]

		'multiple for with key value':
			input: '''
				:for x in list1, y in list2, (key, value) in list3
					"{x}, {y}, {key}{value}
			'''

			expect: [
				[ 'instruction', [ 1, 1 ], 'for'
					[
						[
							['Symbol', 'list1']
							[ 'Symbol', 'x' ]
							undefined, undefined
						]
						[
							['Symbol', 'list2']
							['Symbol', 'y']
							undefined, undefined
						]
						[
							['Symbol', 'list3']
							['Symbol', 'value']
							['Symbol', 'key']
							undefined
						]
					]
					[['text', [ 2, 5 ],
						undefined,
						[[
							[ 'Symbol', 'x' ]
							[ 'String', ', ', ', ' ]
							[ 'Symbol', 'y' ]
							[ 'String', ', ', ', ' ]
							[ 'Symbol', 'key' ]
							[ 'Symbol', 'value' ]
						]]
					]]
				]
			]

		'let simple binding':
			input: '''
				:let x = 10
					"12345{x}
			'''

			expect: [[ 'instruction',
				[ 1, 1 ],
				'let',
				[[[ 'Symbol', 'x' ], [ 'Number', 10 ]]],
				[[
					'text',
					[ 2, 5 ],
					undefined,
					[[[ 'String', '12345', '12345' ],[ 'Symbol', 'x' ]]]
				]]
			]]

		'let binding':
			input: '''
				:let x = 1, y = 2
					"{x}, {y}
			'''

			expect: [[
				'instruction',
				[ 1, 1 ],
				'let',
				[
					[[ 'Symbol', 'x' ], [ 'Number', 1 ]],
					[[ 'Symbol', 'y' ], [ 'Number', 2 ]]
				],
				[[
					'text',
					[ 2, 5 ],
					undefined,
					[[
						[ 'Symbol', 'x' ],
						[ 'String', ', ', ', ' ],
						[ 'Symbol', 'y' ]
					]]
				]]
			]]

		'let binding with pattern match':
			input: '''
				:let [x, y, z] = [1, 2, 3]
					"{x}, {y}
			'''
			expect: [[
				'instruction',
				[ 1, 1 ],
				'let',
				[[
					[
						'ListPattern',
						[[ 'Symbol', 'x' ], [ 'Symbol', 'y' ], [ 'Symbol', 'z' ]]
					],
					[
						'List',
						[[ 'Number', 1 ], [ 'Number', 2 ], [ 'Number', 3 ]]
					]
				]],
				[[
					'text',
					[ 2, 5 ],
					undefined,
					[[[ 'Symbol', 'x' ], [ 'String', ', ', ', ' ], [ 'Symbol', 'y' ]]]
				]]
			]]

		'let binding with named pattern match':
			input: '''
				:let {name:haxName, age} = {name:"hax", age:18}
					"{haxName}, {age}
			'''

		'element':
			input: '''
				div.test1
			'''
			expect: [
				['element', [1, Number], ['div', ['test1'], undefined], undefined, []]
			]

		'element with binding':
			input: '''
				div.test1 = x
			'''
			expect: [
				['element', [1, Number], ['div', ['test1'], undefined], ['Symbol', 'x'], []]
			]

		'element bug 001':
			input: '''
				meta @charset='utf-8'
			'''

			expect: [
				[ 'element', [ 1, 1 ], [ 'meta', '', undefined ], undefined,
					[[ 'attribute', [ 1, Number ], 'charset', '=', [ 'String', 'utf-8' ] ] ] ] ]

		'element double quot':
			input: '''
				meta @charset="utf-8"
			'''
			expect: [
				[ 'element', [ 1, 1 ], [ 'meta', '', undefined ], undefined,
					[[ 'attribute', [ 1, Number ], 'charset', '=',
						[ 'Quasi', undefined, [ [ 'String', 'utf-8', 'utf-8' ] ] ] ]
					]
				]
			]

		'element double quot with x':
			input: '''
				meta @charset="utf-8{x}"
			'''

			expect: [ [ 'element', [ 1, 1 ], [ 'meta', '', undefined ], undefined,
					[ [ 'attribute', [ 1, Number ], 'charset', '=',
						[ 'Quasi', undefined, [ [ 'String', 'utf-8', 'utf-8' ], [ 'Symbol', 'x' ] ] ]
					] ]
				]]

		'nested elements with binding':
			input: '''
				div.test1 > div.test2 = x
					"Hello {user}!
			'''
			expect: [
				['element', [1, Number], ['div', ['test1'], undefined], undefined, [
					['element', [1, Number], ['div', ['test2'], undefined], ['Symbol', 'x'], [
						['text', [Number, Number], undefined, [
							[
								['String', 'Hello ', 'Hello ']
								['Symbol', 'user'],
								['String', '!', '!']
							]
						]]
					]]
				]]
			]
			# should be [1, 13]

		'element with attributes in one line':
			input: "input @required @type='email'"
			expect: [
				['element', [1, Number], ['input', [], undefined], undefined, [
					['attribute', [1, Number], 'required', undefined]
					['attribute', [1, Number], 'type', '=', ['String', 'email']]
				]]
			]
			# should be [1, 7] and [1, 17]

		'nested elements with attribute':
			input: "li > a @href=url"
			expect: [
				['element', [1, Number], ['li', [], undefined], undefined, [
					['element', [1, Number], ['a', [], undefined], undefined, [
						['attribute', [1, Number], 'href', '=', ['Symbol', 'url']]
					]]
				]]
			]
			# should be [1, 6], [1, 8]

		'extend':
			input: ''':import layout'''

			expect: [[
				'instruction',
				[1,1],
				'import',
				'layout',
				''
			]]

		'extend with after hook':
			input: '''
			:import layout
				#headBlock::after
					style @src='test.css'
			'''

			expect:[[
				'instruction',
				[1,1],
				'import',
				'layout',
				[[
					'fragment',
					[ 2, Number ],
					'headBlock',
					'after',
					[[
						'element',
						[ 3, 9 ],
						[ 'style', '', undefined ],
						undefined,
						[[
							'attribute',
							[ 3, Number ],
							'src',
							'=',
							[ 'String', 'test.css' ]
						 ]]
					 ]]
				]]
			]]

		'extend with before hook':
			input: '''
			:import layout
				#headBlock::before
					style @src='test.css'
			'''

			expect:[[
				'instruction',
				[1,1],
				'import',
				'layout',
				[[
					'fragment',
					[ 2, Number ],
					'headBlock',
					'before',
					[[
						'element',
						[ 3, 9 ],
						[ 'style', '', undefined ],
						undefined,
						[[
							'attribute',
							[ 3, Number ],
							'src',
							'=',
							[ 'String', 'test.css' ]
						 ]]
					 ]]
				]]
			]]

		'extend with replace hook':
			input: '''
				:import layout
					#headBlock
						style @src='test.css'
			'''
			expect: [[
				'instruction',
				[1,1],
				'import',
				'layout',
				[[
					'fragment',
					[ 2, Number ],
					'headBlock',
					undefined,
					[[
						'element',
						[ 3, 9 ],
						[ 'style', '', undefined ],
						undefined,
						[[
							'attribute',
							[ 3, Number ],
							'src',
							'=',
							[ 'String', 'test.css' ]
						 ]]
					 ]]
				]]
			]]

		'extend with mutiple hook':
			input: '''
			:import layout
				#headBlock::after
					style @src='test.css'
				#headBlock
					style @src='test.css'
				#headBlock::before
					style @src='test.css'
			'''

			expect:[[
				'instruction',
				[1,1],
				'import',
				'layout',
				[
					[
						'fragment',
						[ 2, Number ],
						'headBlock',
						'after',
						[[
							'element',
							[ 3, Number ],
							[ 'style', '', undefined ],
							undefined,
							[[
								'attribute',
								[ 3, Number ],
								'src',
								'=',
								[ 'String', 'test.css' ]
							 ]]
						 ]]
					]
					[
						'fragment',
						[ Number, Number ],
						'headBlock',
						undefined,
						[[
							'element',
							[ Number, Number ],
							[ 'style', '', undefined ],
							undefined,
							[[
								'attribute',
								[ Number, Number ],
								'src',
								'=',
								[ 'String', 'test.css' ]
							 ]]
						 ]]
					]
					[
						'fragment',
						[ Number, Number ],
						'headBlock',
						'before',
						[[
							'element',
							[ Number, Number ],
							[ 'style', '', undefined ],
							undefined,
							[[
								'attribute',
								[ Number, Number ],
								'src',
								'=',
								[ 'String', 'test.css' ]
							 ]]
						 ]]
					]
				]
			]]
