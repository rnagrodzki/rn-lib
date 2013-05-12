<?php

class SessionTestService
{
    public function startSession()
    {
        session_destroy();
        @session_start();

        return session_id();
    }

    public function getSessionId()
    {
        @session_start();
        return session_id();
    }

    public function setSessionValues($asocArray)
    {
        @session_start();

        foreach ($asocArray as $key => $value)
        {
            $_SESSION[$key] = $value;
        }

        return $_SESSION;
    }

    public function getSessionValues()
    {
        @session_start();
        return $_SESSION;
    }
}
