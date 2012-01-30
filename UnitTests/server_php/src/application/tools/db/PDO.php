<?php

class Tool_Db_PDO
{
    private function __construct()
    {
    }

    /**
     * @var Tool_Db_PDO
     */
    private static $_instance;

    /**
     * @static
     * @return Tool_Db_PDO
     */
    public static function instance()
    {
        if (is_null(self::$_instance)) {
            self::$_instance = new Tool_Db_PDO();
        }

        return self::$_instance;
    }


    /**
     * @var PDO
     */
    private $_pdo;

    public function setup($dsn, $user, $pass, $ops = null)
    {
        $this->_pdo = new PDO($dsn, $user, $pass, $ops);
        $this->_pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    }

    public function call($query, $params = null)
    {
        if (is_null($this->_pdo)) return false;

        $sth = $this->_pdo->prepare($query);
        if ($sth === false) return false;

        $sth->execute($params);

        return $sth->fetchAll(PDO::FETCH_ASSOC);
    }

    public function exec($query)
    {
        if (is_null($this->_pdo)) return;

        return $this->_pdo->exec($query);
    }
}
