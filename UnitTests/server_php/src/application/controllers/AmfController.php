<?php

class AmfController extends Zend_Controller_Action
{

    public function init()
    {
        error_reporting(E_ALL ^ (E_NOTICE | E_WARNING));
        $this->_helper->viewRenderer->setNoRender(true);
    }

    public function indexAction()
    {
        $server = new Zend_Amf_Server();
        $server->addDirectory(APPLICATION_PATH.'/amf/services');

        echo($server->handle());
    }

    /**
     * @static
     * @param $server instance of Zend_Amf_Server
     * @param $alias The alias used for class in ActionScript 3
     * @param $class The mirror class name in PHP
     */
    protected static function registerVO($server,$alias, $class)
    {
        //adding our class to Zend AMF Server
        $server->setClass($class, $alias);
        //Mapping the ActionScript VO to the PHP VO
        $server->setClassMap($alias,$class);
    }
}

