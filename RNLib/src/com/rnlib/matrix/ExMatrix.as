/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.matrix
{
	public class ExMatrix
	{
		public var fields : Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		
		public var dimM:uint;
		public var dimN:uint;
		
		public function ExMatrix()
		{
		}

		public function sum(m:ExMatrix):ExMatrix
		{
			var nm:ExMatrix=new ExMatrix();
			return nm;
		}
	}
}
