(*!------------------------------------------------------------
 * [[APP_NAME]] ([[APP_URL]])
 *
 * @link      [[APP_REPOSITORY_URL]]
 * @copyright Copyright (c) [[COPYRIGHT_YEAR]] [[COPYRIGHT_HOLDER]]
 * @license   [[LICENSE_URL]] ([[LICENSE]])
 *------------------------------------------------------------- *)
program app;

uses

    fano,
    bootstrap;

var
    appInstance : IWebApplication;

begin
    writeln('Starting application at /tmp/fano-fcgi-unix.sock');

    (*!-----------------------------------------------
     * Bootstrap FastCGI application
     *
     * @author AUTHOR_NAME <author@email.tld>
     *------------------------------------------------*)
    appInstance := TDaemonWebApplication.create(
        TFastCgiAppServiceProvider.create(
            TServerAppServiceProvider.create(
                TMyAppServiceProvider.create(),
                (TUnixSvrFactory.create('/tmp/fano-fcgi-unix.sock') as ISocketSvrFactory).build()
            )
        ),
        TMyAppRoutes.create()
    );
    appInstance.run();
end.
