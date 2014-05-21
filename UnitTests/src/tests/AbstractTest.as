/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests
{
	import org.flexunit.rules.IMethodRule;
	import org.morefluent.integrations.flexunit4.MorefluentRule;

	public class AbstractTest
	{
		[Rule]
		// make sure you have MorefluentRule defined in your test
		public var morefluentRule:IMethodRule = new MorefluentRule();

		protected var _firstRun:Boolean = true;

		public function setupClass():void
		{

		}

		[Before]
		public function setup():void
		{
			if(_firstRun)
			{
				_firstRun = false;
				setupClass();
			}
		}

		[After]
		public function tearDown():void
		{

		}
	}
}
