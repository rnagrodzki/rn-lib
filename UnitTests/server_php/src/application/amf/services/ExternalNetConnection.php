<?php

class ExternalNetConnection
{
    /**
     * Simple method with returning value
     * @return string
     */
    public function simple()
    {
        return "Successfully connected to service";
    }

    /**
     * Method throw Exception
     */
    public function throwException()
    {
        throw new Exception("Test with exception",100);
    }
}
