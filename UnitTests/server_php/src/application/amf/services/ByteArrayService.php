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
        return new Zend_Amf_Value_ByteArray($ba);
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
        return new Zend_Amf_Value_ByteArray($vo->bytes);
    }


    // -------------- SAVING AND LOADING FILE ------------------


    protected $fileName = "testPartFile.png";

    protected function getDir()
    {
        $dir = realpath(dirname(__FILE__) . '/../../../');
        $dir .= '/uploads';

        if (!is_dir($dir))
            mkdir($dir);

        return $dir;
    }

    protected function getFullFileName()
    {
        return $this->getDir() . '/' . $this->fileName;
    }

    public function startSavingFile($content)
    {
        if (file_exists($this->getFullFileName()))
            unlink($this->getFullFileName());

        $result = file_put_contents($this->getFullFileName(), $content);

        return array(__FILE__, $this->getDir(), $this->getFullFileName(),$result);
    }

    public function continueSavingFile($content)
    {
        file_put_contents($this->getFullFileName(), $content, FILE_APPEND);
        return filesize($this->getFullFileName());
    }

    public function loadFile()
    {
        return new Zend_Amf_Value_ByteArray(file_get_contents($this->getFullFileName()));
//        return file_get_contents($this->getFullFileName());
    }
}
