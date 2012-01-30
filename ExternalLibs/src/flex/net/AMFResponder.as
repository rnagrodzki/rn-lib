////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.net 
{

/**
 * Default implementation of IAMFResponder.
 */
public class AMFResponder implements IAMFResponder 
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructs a new AMFResponder.
     */
    public function AMFResponder(result:Function, status:Function)
    {
        _resultHandler = result;
        _statusHandler = status;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    public function amfResult(data:Object):void
    {
        _resultHandler(data);
    }

    public function amfStatus(info:Object):void
    {
        _statusHandler(info);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _resultHandler:Function;
    private var _statusHandler:Function;
}

}