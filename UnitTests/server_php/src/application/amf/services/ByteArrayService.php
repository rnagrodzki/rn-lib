<?php

class ByteArrayService
{
    public function loadByteArray()
    {
        $source = "Example txt";
        $vo = new Zend_Amf_Value_ByteArray($source);

        return $vo;
    }

    public function sendAndLoadByteArray($ba)
    {
        return new Zend_Amf_Value_ByteArray( $ba );
    }

    public function loadAsDump($p)
    {
        try {
            ob_start();
            var_dump($p);
            $dump = ob_get_contents();
            ob_clean();
        } catch (Exception $e) {
            return $e->getMessage();
        }

        return $dump;
    }

    public function byteArrayFromVO(Amf_VO_ByteArray $vo)
    {
        return new Zend_Amf_Value_ByteArray( $vo->bytes );
    }
}
