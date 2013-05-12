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

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class FileCacheManager implements IResponseCacheManager, IDisposable
	{
		public function FileCacheManager(file:File)
		{
			_file = file;
			initialize();
		}

		//---------------------------------------------------------------
		//              <------ INTERFACE ------>
		//---------------------------------------------------------------

		public function isCached(id:Object):Boolean
		{
			if (!_cache)
				return false;

			return _cache[id] !== undefined;
		}

		public function getResponse(id:Object):*
		{
			if (!_cache)
				return null;

			return read(id);
		}

		public function removeResponse(id:Object):Boolean
		{
			if (!_cache)
				return false;
			return remove(id);
		}

		public function setResponse(id:Object, response:*, storageTime:int = -1):Boolean
		{
			if (!_cache)
				return false;
			return save(id, response, storageTime);
		}

		public function dispose():void
		{
			_cache = null;
		}

		//---------------------------------------------------------------
		//              <------ INTERNAL ------>
		//---------------------------------------------------------------

		protected var _file:File;

		protected var _cache:Dictionary;

		protected function initialize():void
		{
			registerClassAlias("respVO", ResponseVO);
			registerClassAlias("dict", Dictionary);
			registerClassAlias("ba", ByteArray);

			if (!_file.isDirectory)
				throw new Error("Passed File reference must point to existing directory: " + _file.nativePath);

			var files:Array = _file.getDirectoryListing();
			_cache = new Dictionary();

			for each (var dataFile:File in files)
			{
				_cache[dataFile.name] = new FilePromiseVO(dataFile);
			}
		}

		protected function save(id:Object, response:*, storageTime:int = -1):Boolean
		{
			if (!_file) return false;

			remove(id); // remove before write new version

			var promise:FilePromiseVO = new FilePromiseVO(_file.resolvePath(id as String));
			_cache[id] = promise;

			var stream:FileStream = new FileStream();
			stream.open(promise.file, FileMode.WRITE);
			stream.writeObject(new ResponseVO(response, storageTime));
			stream.close();

			return true;
		}

		protected function remove(id:Object):Boolean
		{
			if (_cache[id] is FilePromiseVO)
			{
				FilePromiseVO(_cache[id]).file.deleteFile();
				delete _cache[id];
				return true;
			}

			return false;
		}

		protected function read(id:Object):*
		{
			if (_cache[id] is FilePromiseVO)
			{
				var stream:FileStream = new FileStream();
				stream.open(FilePromiseVO(_cache[id]).file, FileMode.READ);
				var response:ResponseVO = stream.readObject();
				stream.close();

				return response.content;
			}
		}
	}
}

import flash.filesystem.File;

class FilePromiseVO
{
	public function FilePromiseVO(f:File)
	{
		file = f;
	}

	public var file:File;
}

class ResponseVO
{
	public function ResponseVO(c:* = undefined, e:int = -1)
	{
		content = c;
		expire = e;
	}

	public var content:*;
	public var expire:int;
}
