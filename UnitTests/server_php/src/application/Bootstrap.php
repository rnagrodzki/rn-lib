<?php

class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
    protected function _initAutoloader()
    {
        $loader = new Zend_Loader_Autoloader_Resource(array(
            'basePath' => APPLICATION_PATH,
            'namespace' => ''
        ));

        $loader->addResourceType('amf', 'amf', 'Amf');
        $loader->addResourceType('model', 'models', 'Model');
        $loader->addResourceType('tool', 'tools', 'Tool');
        return $loader;
    }
}

