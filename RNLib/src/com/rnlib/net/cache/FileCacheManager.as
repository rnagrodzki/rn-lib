/***************************************************************************************************
 * Copyright (c) 2012 Rafał Nagrodzki (http://nagrodzki.net)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package com.rnlib.net.cache
{
	import com.rnlib.interfaces.IDisposable;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;

	public class FileCacheManager implements IResponseCacheManager, IDisposable
	{
		public function FileCacheManager(file:File)
		{
			_file = file.clone();
			initialize();
		}

		//---------------------------------------------------------------
		//              <------ INTERFACE ------>
		//---------------------------------------------------------------

		public function isCached(id:String):Boolean
		{
			if (!_cache)
				return false;

			return _cache[id] !== undefined;
		}

		public function getResponse(id:String):*
		{
			if (!_cache)
				return null;

			return _cache[id].content;
		}

		public function removeResponse(id:String):Boolean
		{
			if (!_cache)
				return false;

			_cache[id] = undefined;
			return flush();
		}

		public function setResponse(id:String, response:*, storageTime:int = -1):Boolean
		{
			if (!_cache)
				return false;

			_cache[id] = new ResponseVO(response, storageTime);
			return flush();
		}

		public function invalidateCache():void
		{
			_cache = {};
			flush();
		}

		public function dispose():void
		{
			_cache = null;
		}

		//---------------------------------------------------------------
		//              <------ INTERNAL ------>
		//---------------------------------------------------------------

		protected var _file:File;

		protected var _cache:Object;

		protected function initialize():void
		{
			registerClassAlias(getQualifiedClassName(ResponseVO), ResponseVO);

			_file.addEventListener(Event.COMPLETE, onComplete);
			_file.load();
		}

		private function onComplete(e:Event):void
		{
			_cache = _file.data.readObject();
		}

		protected function flush():Boolean
		{
			if (!_file) return false;

			var stream:FileStream = new FileStream();
			stream.open(_file, FileMode.WRITE);
			stream.writeObject(_cache);
			stream.close();
			return true;
		}
	}
}

class ResponseVO
{
	public function ResponseVO(c:*, e:int)
	{
		content = c;
		expire = e;
	}

	public var content:*;
	public var expire:int;
}
