////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.net
{

/**
 * This interface provides a contract for calls made to an AMFConnection.
 */
public interface IAMFResponder
{
    function amfResult(data:Object):void;

    function amfStatus(info:Object):void;
}

}
