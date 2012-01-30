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

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.ObjectEncoding;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.utils.ByteArray;

[Event(name="progress", type="flash.events.ProgressEvent")]

[Event(name="complete", type="flash.events.Event")]

[Event(name="ioError", type="flash.events.IOErrorEvent")]

[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

/**
 * An ActionScript alternative to the native flash.net.NetConnection class for
 * sending AMF formatted requests over HTTP or HTTPS.
 * 
 * The default AMF object encoding version is AMF 3. However, AMF formatted
 * network requests always start with AMF 0 encoding and if the version is
 * set to AMF 3, the encoder only switches to AMF 3 on the first complex type
 * encountered. (A complex type is considered to be a value that is not null,
 * undefined, a Boolean, a String, a Number, an int or a uint).
 * 
 * @author pfarland@adobe.com
 * @version 0.1
 */
public class AMFConnection extends EventDispatcher
{
    //--------------------------------------------------------------------------
    //
    // Constructor
    // 
    //--------------------------------------------------------------------------

    /**
     * Creates a new AMFConnection instance.
     * 
     * @param url The HTTP or HTTPS URL for the connection.   
     */
    public function AMFConnection(url:String=null)
    {
        super();
        connect(url);
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    //----------------------------------
    //  client
    //----------------------------------

    /**
     * A client can be configured to receive notification of AMF response
     * headers. If the client instance defines a suitable function of the same
     * name as an AMF response header it will be invoked. The value of the
     * header will be passed as the only argument.
     */ 
    public function get client():Object
    {
        return _client;
    }

    public function set client(value:Object):void
    {
        _client = value;
    }


    //----------------------------------
    //  connected
    //----------------------------------

    /**
     * Determines whether a connection exists.
     */ 
    public function get connected():Boolean
    {
        return _connected;
    }


    //----------------------------------
    //  defaultObjectEncoding
    //----------------------------------

    /**
     * The default object encoding for all AMFConnection instances. This
     * controls which version of AMF is used during serialization. The default
     * is AMF 3.
     * 
     * @see #objectEncoding
     * @see flash.net.ObjectEncoding
     */ 
    public static function get defaultObjectEncoding():uint
    {
        return _defaultObjectEncoding;
    }

    public static function set defaultObjectEncoding(value:uint):void
    {
        _defaultObjectEncoding = value;
    }


    //----------------------------------
    //  objectEncoding
    //----------------------------------

    /**
     * The object encoding for this AMFConnection sets which AMF version to
     * use during serialization. If set, this version overrides the
     * defaultObjectEncoding.
     * 
     * @see #defaultObjectEncoding
     * @see flash.net.ObjectEncoding
     */ 
    public function get objectEncoding():uint
    {
        if (!objectEncodingSet)
            return defaultObjectEncoding;

        return _objectEncoding;
    }

    public function set objectEncoding(value:uint):void
    {
        _objectEncoding = value;
        objectEncodingSet = true;
    }


    //----------------------------------
    //  url
    //----------------------------------

    /**
     * The HTTP or HTTPS url for the AMFConnection.
     */ 
    public function get url():String
    {
        return _url;
    }

    [Deprecated("Please use the 'url' property instead.")]
    public function get uri():String
    {
        return _url;
    }

    //--------------------------------------------------------------------------
    //
    // Protected Variables
    // 
    //--------------------------------------------------------------------------

    /**
     * Sequentially incremented counter used to generate a unique responseURI
     * to match response messages to responders.
     */ 
    protected var responseCounter:uint;

    /**
     * The URLLoader used to make AMF formatted HTTP and HTTPS requests for
     * this connection.
     */ 
    protected var urlLoader:URLLoader;

    /**
     * Manages a list of all pending requests. Each request must implement
     * flex.net.IAMFResponder.
     */
    protected var pendingRequests:Object = {};


    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------

    /**
     * Adds an AMF packet-level header which is sent with every request for
     * the life of this AMFConnection.
     */ 
    public function addHeader(name:String, mustUnderstand:Boolean=false, data:*=undefined):void
    {
        if (_amfHeaders == null)
            _amfHeaders = [];

        var header:AMFHeader = new AMFHeader(name, mustUnderstand, data);
        _amfHeaders.push(header);
    }

    /**
     * Makes an AMF request to the server. A connection must have been made
     * prior to making a call. 
     */ 
    public function call(command:String, responder:IAMFResponder, ...arguments:Array):void
    {
        var responseURI:String = getResponseURI();
        pendingRequests[responseURI] = responder;

        // TODO: Support customizable batching of messages
        var request:AMFPacket = new AMFPacket(objectEncoding);
        request.headers = _amfHeaders;

        var message:AMFMessage = new AMFMessage(command, responseURI, arguments);
        request.messages.push(message);

        var data:ByteArray = encodeRequest(request);
        send(data);
    }

    /**
     * Closes the connection and clears any pending requests.
     */ 
    public function close():void
    {
        _connected = false;
        pendingRequests = {}; 
        urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
        urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        urlLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
        urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

        // TODO: Confirm this event is never dispatched by URLLoader
        urlLoader.removeEventListener(ErrorEvent.ERROR, errorHandler);
        
        try
        {
            urlLoader.close();
        }
        catch (e:Error)
        {
        }

        urlLoader = null;
    }

    /**
     * Connects to the URL provided. Any previous connections are closed and
     * any outstanding requests are cleared.
     */ 
    public function connect(url:String):void
    {
        if (urlLoader != null)
            close();

        _url = url;
        urlLoader = new URLLoader();
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        urlLoader.addEventListener(Event.COMPLETE, completeHandler);
        urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

        //TODO: Confirm this event is never dispatched by URLLoader
        urlLoader.addEventListener(ErrorEvent.ERROR, errorHandler);

        _connected = true;
    }

    /**
     * Removes any AMF headers found with the name given.
     * 
     * @param name The name of the header(s) to remove.
     * 
     * @return true if a header existed with the given name.
     */ 
    public function removeHeader(name:String):Boolean
    {
        var exists:Boolean = false;

        if (_amfHeaders != null)
        {
            for (var i:uint = 0; i < _amfHeaders.length; i++)
            {
                var header:AMFHeader = _amfHeaders[i] as AMFHeader;
                if (header.name == name)
                {
                    _amfHeaders.splice(i, 1);
                    exists = true;
                }
            }
        }

        return exists;
    }

    //--------------------------------------------------------------------------
    //
    // Event Handlers
    // 
    //--------------------------------------------------------------------------

    protected function completeHandler(event:Event):void
    {
        var data:ByteArray = urlLoader.data as ByteArray;
        response(data);
        dispatchEvent(event);
    }

    protected function errorHandler(event:ErrorEvent):void
    {
        dispatchEvent(event);
    }

    protected function httpStatusHandler(event:HTTPStatusEvent):void
    {
        dispatchEvent(event);
    }

    protected function ioErrorHandler(event:IOErrorEvent):void
    {
        dispatchEvent(event);
    }

    protected function progressHandler(event:ProgressEvent):void
    {
        dispatchEvent(event);
    }

    protected function securityErrorHandler(event:SecurityErrorEvent):void
    {
        dispatchEvent(event);
    }

    //--------------------------------------------------------------------------
    //
    // Protected Methods
    // 
    //--------------------------------------------------------------------------

    protected function getResponseURI():String
    {
        var responseURI:String = "/" + responseCounter;
        responseCounter++;
        return responseURI;
    }

    protected function response(bytes:ByteArray):void
    {
        var response:AMFPacket = decodeResponse(bytes);

        // Report AMF headers to a configured client, if present
        for each (var header:AMFHeader in response.headers)
        {
            try
            {
                var headerHandler:Function;
                if (client != null)
                {
                    headerHandler = client[header.name];
                    if (headerHandler != null)
                    {
                        headerHandler.apply(null, [header.data]);
                    }
                }

                if (headerHandler == null && header.mustUnderstand)
                {
                    // TODO: Report fault event?
                }
            }
            catch (e:Error)
            {
            }
        }

        // Report result or status to the matching responder
        for each (var message:AMFMessage in response.messages)
        {
            var targetURI:String = message.targetURI;
            var separator:int = targetURI.indexOf("/", 1);
            var requestId:String = targetURI.substring(0, separator);
            var responseType:String = targetURI.substring(separator + 1);

            var responder:IAMFResponder = pendingRequests[requestId];
            delete pendingRequests[requestId];

            if (responder != null)
            {
                if (responseType == "onResult")
                    responder.amfResult(message.body);
                else if (responseType == "onStatus")
                    responder.amfStatus(message.body);
            }
        }
    }

    protected function send(data:ByteArray):void
    {
        var urlRequest:URLRequest = new URLRequest(url);
        urlRequest.contentType = AMF_CONTENT_TYPE;
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.data = data;
        urlLoader.load(urlRequest);
    }

    //--------------------------------------------------------------------------
    //
    // Private Methods
    // 
    //--------------------------------------------------------------------------

    private static function decodeResponse(bytes:ByteArray):AMFPacket
    {
        // AMF Version
        var version:int = bytes.readUnsignedShort();

        // The response must always start in AMF0
        bytes.objectEncoding = ObjectEncoding.AMF0;
        var response:AMFPacket = new AMFPacket(); 

        var remainingBytes:ByteArray;

        // Headers
        var headerCount:uint = bytes.readUnsignedShort();
        for (var h:uint = 0; h < headerCount; h++)
        {
            var headerName:String = bytes.readUTF();
            var mustUnderstand:Boolean = bytes.readBoolean();
            bytes.readInt(); // Consume header length...

            // Handle AVM+ type marker
            if (version == ObjectEncoding.AMF3)
            {
                var typeMarker:int = bytes.readByte(); 
                if (typeMarker == AVMPLUS_TYPE_MARKER)
                    bytes.objectEncoding = ObjectEncoding.AMF3;
                else
                    bytes.position = bytes.position - 1;
            }

            var headerValue:* = bytes.readObject();

            // Read off the remaining bytes to account for the reset of 
            // the by-reference index on each header value
            remainingBytes = new ByteArray();
            remainingBytes.objectEncoding = bytes.objectEncoding;
            bytes.readBytes(remainingBytes, 0, bytes.length - bytes.position);
            bytes = remainingBytes;
            remainingBytes = null;

            var header:AMFHeader = new AMFHeader(headerName, mustUnderstand, headerValue);
            response.headers.push(header);

            // Reset to AMF0 for next header
            bytes.objectEncoding = ObjectEncoding.AMF0;
        }

        // Message Bodies
        var messageCount:uint = bytes.readUnsignedShort();
        for (var m:uint = 0; m < messageCount; m++)
        {
            var targetURI:String = bytes.readUTF();
            var responseURI:String = bytes.readUTF();
            bytes.readInt(); // Consume message body length...

            // Handle AVM+ type marker
            if (version == ObjectEncoding.AMF3)
            {
                if (bytes.readByte() == AVMPLUS_TYPE_MARKER)
                    bytes.objectEncoding = ObjectEncoding.AMF3;
                else
                    bytes.position = bytes.position - 1;
            }

            var messageBody:* = bytes.readObject();

            // Read off the remaining bytes to account for the reset of 
            // the by-reference index on each message body
            remainingBytes = new ByteArray();
            remainingBytes.objectEncoding = bytes.objectEncoding;
            bytes.readBytes(remainingBytes, 0, bytes.length - bytes.position);
            bytes = remainingBytes;
            remainingBytes = null;

            var message:AMFMessage = new AMFMessage(targetURI, responseURI, messageBody);
            response.messages.push(message);

            // Reset to AMF0 for next message
            bytes.objectEncoding = ObjectEncoding.AMF0;
        }

        return response;
    }

    private static function encodeRequest(request:AMFPacket):ByteArray
    {
        var bytes:ByteArray = new ByteArray();
        bytes.objectEncoding = ObjectEncoding.AMF0;

        // AMF Version
        bytes.writeShort(request.version);

        var bytesBuffer:ByteArray;

        // AMF Headers
        var headerCount:uint = request.headers == null ? 0 : request.headers.length;
        bytes.writeShort(headerCount);

        for each (var header:AMFHeader in request.headers)
        {
            bytes.writeUTF(header.name);
            bytes.writeBoolean(header.mustUnderstand);
            bytes.writeInt(UNKNOWN_CONTENT_LENGTH);
            
            // AMF 3 requires AMF 0 switch type marker
            if (request.version == ObjectEncoding.AMF3)
                bytes.writeByte(AVMPLUS_TYPE_MARKER);
            bytes.objectEncoding = request.version;

            // Write the header value into a temporary buffer to ensure the
            // the by-reference index is reset between values
            bytesBuffer = new ByteArray();
            bytesBuffer.objectEncoding = bytes.objectEncoding;
            bytesBuffer.writeObject(header.data);
            bytesBuffer.position = 0;
            bytes.writeBytes(bytesBuffer, 0, bytesBuffer.length);
            bytesBuffer = null;

            // Reset back to AMF 0 for next header 
            bytes.objectEncoding = ObjectEncoding.AMF0;
        }

        // AMF Message Bodies
        var messageCount:uint = request.messages == null ? 0 : request.messages.length;
        bytes.writeShort(messageCount);

        for each (var message:AMFMessage in request.messages)
        {
            if (message.targetURI == null)
                bytes.writeUTF("null");
            else
                bytes.writeUTF(message.targetURI);

            if (message.responseURI == null)
                bytes.writeUTF("null");
            else
                bytes.writeUTF(message.responseURI);

            bytes.writeInt(UNKNOWN_CONTENT_LENGTH);

            // AMF 3 requires AMF 0 switch type marker
            if (request.version == ObjectEncoding.AMF3)
                bytes.writeByte(AVMPLUS_TYPE_MARKER);

            bytes.objectEncoding = request.version; 

            // Write the header value into a temporary buffer to ensure the
            // the by-reference index is reset between values
            bytesBuffer = new ByteArray();
            bytesBuffer.objectEncoding = bytes.objectEncoding;
            bytesBuffer.writeObject(message.body);
            bytesBuffer.position = 0;
            bytes.writeBytes(bytesBuffer, 0, bytesBuffer.length);
            bytesBuffer = null;

            // Reset back to AMF 0 for next message
            bytes.objectEncoding = ObjectEncoding.AMF0;
        }

        bytes.position = 0;
        return bytes;
    }

    /**
     * A value is considered complex if it is not null, undefined, a String,
     * a Boolean, a Number, an int, or a uint.
     * 
     * TODO: Use this to determine whether the switch to AMF 3 should occur
     * before writing out the AVMPLUS_TYPE_MARKER for header and message
     * bodies. 
     */ 
    private static function isComplexType(value:*):Boolean
    {
        return (value == null || value is String || value is Boolean
            || value is Number || value is int || value is uint);
    }

    //--------------------------------------------------------------------------
    //
    // Private Variables
    // 
    //--------------------------------------------------------------------------

    private var _amfHeaders:Array; // Array of AMFHeader
    private var _client:Object;
    private var _connected:Boolean;
    private var _objectEncoding:uint;
    private var objectEncodingSet:Boolean = false;
    private var _url:String;

    private static var _defaultObjectEncoding:uint = ObjectEncoding.AMF3;


    //--------------------------------------------------------------------------
    //
    // Constants
    // 
    //--------------------------------------------------------------------------

    private static const AMF_CONTENT_TYPE:String = "application/x-amf";
    private static const UNKNOWN_CONTENT_LENGTH:int = -1;
    private static const AVMPLUS_TYPE_MARKER:uint = 17;
}

}

//--------------------------------------------------------------------------
//
// Private Inner Classes
// 
//--------------------------------------------------------------------------

/**
 * An AMFPacket represents a single AMF request made over an HTTP or 
 * HTTPS connection. An AMFPacket can have multiple AMFHeaders followed by a 
 * batch of multiple AMFMessages.
 */ 
class AMFPacket
{
    public function AMFPacket(version:uint=0)
    {
        this.version = version;
    }

    public var version:uint;
    public var headers:Array = []; // Array of AMFHeader
    public var messages:Array = []; // Array of AMFMessage
}

/**
 * An AMF packet level header. Request and response headers have an identical
 * structure.
 * 
 * When making use of by-reference serialization, the reference tables are
 * reset for each AMFHeader. Note that the header name String is never sent by
 * reference and does not participate in by-reference serialization.
 */
class AMFHeader
{
    public function AMFHeader(name:String, mustUnderstand:Boolean=false, data:*=undefined)
    {
        this.name = name;
        this.mustUnderstand = mustUnderstand;
        this.data = data;
    }

    public var name:String;
    public var mustUnderstand:Boolean;
    public var data:*;
}

/**
 * An AMF packet level message. Request messages and response messages have the
 * same general structure.
 * 
 * For requests, the targetURI specifies the location of the resource and the
 * operation being invoked. The responseURI specifies the URI that the server
 * must use in its response targetURI as this helps the client match it to the
 * associated request message (and thus the correct message responder can be
 * invoked).
 * 
 * For responses, the server uses the targetURI to identify to the client 
 * which message this response is intended. The responseURI is ignored. 
 * 
 * When making use of by-reference serialization, the reference tables are
 * reset for each AMFMessage. Note that targetURI and responseURI Strings are
 * never sent by reference and do not participate in by-reference serialization.
 */
class AMFMessage
{
    public function AMFMessage(targetURI:String=null, responseURI:String=null, body:*=undefined)
    {
        this.targetURI = targetURI;
        this.responseURI = responseURI;
        this.body = body;
    }

    public var targetURI:String;
    public var responseURI:String;
    public var body:*;
}
