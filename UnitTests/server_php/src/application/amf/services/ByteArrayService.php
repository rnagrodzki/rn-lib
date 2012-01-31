<?php

class ByteArrayService
{
    public function loadBitmapArray()
    {
        $source = "Example txt";
        $vo = new Zend_Amf_Value_ByteArray($source);

        return $vo;
    }

    public function sendAndLoadByteArray($ba)
    {
        return $ba;
    }

    public function loadAsDump($p)
    {
        ob_start();
        var_dump($p);
        $dump = ob_get_contents();
        ob_clean();

        return $dump;
    }
}
