#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""

Usage:
    script.py [options]
    script.py (-h | --help)
    script.py --version

Options:
    -h --help               Show this screen.
    --version               Show version.
    --loglevel, -L=<str>    Loglevel
                            (ERROR, CRITICAL, WARN, INFO, DEBUG)
    --log2stdout, -l        Log to stdout, otherwise to logfile.
    --logfile, -f=<path>    Logfile to log to (default: <scriptname>.log)
    --cfg, -c=<path>        Configuration file. [default: /etc/qnib_consul.cfg]

"""

# load librarys
import logging
import os
import re
import codecs
import ast
from ConfigParser import RawConfigParser, NoOptionError
import consul

try:
    from docopt import docopt
except ImportError:
    HAVE_DOCOPT = False
else:
    HAVE_DOCOPT = True

__author__    = 'Christian Kniep <christian()qnib.org>'
__copyright__ = 'Copyright 2014 Christian Kniep'
__license__   = """MIT License (http://opensource.org/licenses/MIT)"""


class QnibConfig(RawConfigParser):
    """ Class to abstract config and options
    """
    specials = {
            'TRUE'  : True,
            'FALSE' : False,
            'NONE'  : None,
        }
    def __init__(self, opt):
        """ init """
        RawConfigParser.__init__(self)
        if opt is None:
            self._opt = {
            "--log2stdout": False,
            "--logfile": None,
            "--loglevel": "ERROR",
            }
        else:
            self._opt = opt
        
        ### Defaults
        self.logformat = '%(asctime)-15s %(levelname)-5s [%(module)s] %(message)s'
        
        ### eval if opt is set
        self.eval_cfg()
        self.eval_opt()
        self.set_logging()
        logging.info("SetUp of QnibConfig is done...")
    
    def do_get(self, section, key, default=None):
        """ Also lent from: https://github.com/jpmens/mqttwarn
        """
        try:
            val = self.get(section, key)
            if val.upper() in self.specials:
                return self.specials[val.upper()]
            return ast.literal_eval(val)
        except NoOptionError:
            return default
        except ValueError:   # e.g. %(xxx)s in string
            return val
        except:
            raise
            return val
    
    def config(self, section):
        ''' Convert a whole section's options (except the options specified
            explicitly below) into a dict, turning

                [config:mqtt]
                host = 'localhost'
                username = None
                list = [1, 'aaa', 'bbb', 4]

            into

                {u'username': None, u'host': 'localhost', u'list': [1, 'aaa', 'bbb', 4]}

            Cannot use config.items() because I want each value to be
            retrieved with g() as above
        SOURCE: https://github.com/jpmens/mqttwarn
        '''

        d = None
        if self.has_section(section):
            d = dict((key, self.do_get(section, key))
                for (key) in self.options(section) if key not in ['targets'])
        return d
    
    def eval_cfg(self):
        """ eval configuration which overrules the defaults
        """
        cfg_file = self._opt.get('--cfg')
        if cfg_file is not None:
            fd = codecs.open(cfg_file, 'r', encoding='utf-8')
            self.readfp(fd)
            fd.close()
            self.__dict__.update(self.config('defaults'))
    
    
    def eval_opt(self):
        """ Updates cfg according to options """
        def handle_logfile(val):
            """ transforms logfile argument
            """
            if val is None:
                logf = os.path.splitext(os.path.basename(__file__))[0]
                self.logfile = "%s.log" % logf.lower()
            else:
                self.logfile = val
                
        self._mapping = {
            '--logfile': lambda val: handle_logfile(val),
        }
        for key, val in self._opt.items():
            if key in self._mapping:
                if isinstance(self._mapping[key], str):
                    self.__dict__[self._mapping[key]] = val
                else:
                    self._mapping[key](val)
                break
            else:
                if val is None:
                    continue
                mat = re.match("\-\-(.*)", key)
                if mat:
                    self.__dict__[mat.group(1)] = val
                else:
                    logging.info("Could not find opt<>cfg mapping for '%s'" % key)
    
    def set_logging(self):
        """ sets the logging """
    
        if self.log2stdout:
            logging.basicConfig(level=self.loglevel,
                                format=self.logformat)
        else:
            logging.basicConfig(filename=self.logfile,
                                level=self.loglevel,
                                format=self.logformat)

    def __str__(self):
        """ print human readble """
        ret = []
        for key, val in self.__dict__.items():
            if not re.match("_.*", key):
                ret.append("%-15s: %s" % (key, val))
        return "\n".join(ret)
                    



class QnibConsul(object):
    """ Fetch information from consul's API
    """

    def __init__(self, cfg):
        """ Init of instance
        """
        self._cfg = cfg
        self._consul = consul.Consul(host='consul.service.consul', port=8500)
        

    def do_sth(self):
        """ does sth
        """
        for item in self._consul.agent.members():
            print item['Name']


def main():
    """ main function """
    options = None
    if HAVE_DOCOPT:
        options = docopt(__doc__,  version='0.1')
    qcfg = QnibConfig(options)
    con = QnibConsul(qcfg)
    con.do_sth()

if __name__ == "__main__":
    main()
