/**
 * @author Rafal Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package com.rnlib.utils
{
	import mx.core.IFactory;

	public class ExtendedClassFactory implements IFactory
	{
		public var generator:Class;
		public var init:Function;
		public var properties:Object;

		public function ExtendedClassFactory(generator:Class, init:Function = null, properties:Object = null)
		{
			this.generator = generator;
			this.init = init;
			this.properties = properties;
		}

		public function newInstance():*
		{
			var instance:* = new generator();
			if (init !== null) init(instance);
			if (properties !== null)
			{
				for (var prop:String in properties)
				{
					instance[prop] = properties[prop];
				}
			}
			return instance;
		}
	}
}
