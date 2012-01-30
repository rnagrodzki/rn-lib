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

    public function arrayFunction()
    {
        return array(
            "key1" => "val1",
            0 => "value 0",
            1 => "value 1");
    }

    public function testVO()
    {
        $vo = new Amf_VO_Test();
        $vo->name = "Test name";
        $vo->count = 25;
        return $vo;
    }

    /**
     * Method throw Exception
     */
    public function throwException()
    {
        throw new Exception("Test with exception", 100);
    }
}
