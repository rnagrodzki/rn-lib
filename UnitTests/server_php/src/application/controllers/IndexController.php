<?php

class IndexController extends Zend_Controller_Action
{

    public function init()
    {
        /* Initialize action controller here */
        $this->_helper->viewRenderer->setNoRender(true);
    }

    public function indexAction()
    {
        // action body
    }
}

