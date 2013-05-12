<?php

class ExamplesService
{
    public function getTime( $str = null )
    {
        sleep(2);
        return $str . ' ' . time();
    }
}
