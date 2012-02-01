<?php

class BaseAMFService
{
    /**
     * Simple method with returning value
     * @return string
     */
    public function loadString()
    {
        return "Successfully connected to service";
    }

    public function loadArray()
    {
        return array(
            "key1" => "val1",
            0 => "value 0",
            1 => "value 1");
    }

    public function loadVO()
    {
        $vo = new Amf_VO_Test();
        $vo->name = "Test name";
        $vo->count = 25;
        return $vo;
    }

    public function loadAsDump($p)
    {
        ob_start();
        var_dump($p);
        $dump = ob_get_contents();
        ob_clean();

        return $dump;
    }

    public function loadCurrentDate()
    {
//        return date('Y-m-d H:i:s',time());
//        return time();
        return new DateTime();
    }

    /**
     * Method throw Exception
     */
    public function throwException()
    {
        throw new Exception("Test with exception", 100);
    }
}
