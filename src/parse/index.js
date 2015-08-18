export const parseFile = filename => {
	const lines = splitLines(readFile(filename))
	const tree = parseLines(lines)
	return ['document', [filename, 1, 1], lines, undefined, tree]
}

import {readFileSync} from 'fs'
const readFile = filename => readFileSync(filename).toString()

const splitLines = s => s.split(/\r?\n|[\u2028\u2029]/)

import memoize from '../util/memoize'
import {Parser} from './parser'
const match = Parser.match::memoize()
export const parseLines = lines => Parser::match(lines, 'block')
