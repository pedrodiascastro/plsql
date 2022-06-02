CREATE OR REPLACE 
PROCEDURE send_html_mail
          (i_to        IN VARCHAR2,
           i_from      IN VARCHAR2,
           i_nome      IN VARCHAR2,
           i_subject   IN VARCHAR2,
           i_text_msg  IN VARCHAR2  DEFAULT NULL,
           i_html_msg  IN clob      DEFAULT NULL,
           i_smtp_host IN VARCHAR2,
           i_smtp_port IN NUMBER    DEFAULT 25,
           i_tipo_logo IN NUMBER    DEFAULT 1,
           i_cc        IN VARCHAR2 DEFAULT NULL,
           i_bcc       IN VARCHAR2 DEFAULT NULL)
AS

  TYPE t_split_array IS TABLE OF VARCHAR2(4000);

  l_mail_conn   UTL_SMTP.connection;
  l_boundary    VARCHAR2(50) := '----=*#abc1234321cba#*=';
  l_boundary3   VARCHAR2(50) := '----=*#4321edcba1234#*=';
  l_logotipo    CLOB;
  lv_nr_logotipo number;
  lv_ch_logotipo varchar2(10);

  --
  -- Logotipos a ser incluidos no email
  --
  CURSOR C_LOGOTIPOS IS
    select C_LOGO
    FROM logotipos
    where ID_LOGO=i_tipo_logo
    ORDER BY ORDEM;

  --
  -- Funcao auxiliar para separar texto por um determinado delimitador
  --
  FUNCTION split_text (p_text IN CLOB, p_delimeter IN VARCHAR2 DEFAULT ',')
  RETURN t_split_array IS
      l_array  t_split_array   := t_split_array();
      l_text   CLOB := p_text;
      l_idx    NUMBER;
  BEGIN
      l_array.delete;

      IF l_text IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'P_TEXT parameter cannot be NULL');
      END IF;

      WHILE l_text IS NOT NULL LOOP
        l_idx := INSTR(l_text, p_delimeter);
        l_array.extend;
        IF l_idx > 0 THEN
          l_array(l_array.last) := SUBSTR(l_text, 1, l_idx - 1);
          l_text := SUBSTR(l_text, l_idx + 1);
        ELSE
          l_array(l_array.last) := l_text;
          l_text := NULL;
        END IF;
      END LOOP;
      RETURN l_array;
  END split_text;

  --
  -- Procedimento que adiciona os destinatarios do email (TO, CC e BCC)
  --
  PROCEDURE process_recipients(p_mail_conn IN OUT UTL_SMTP.connection,p_list IN VARCHAR2)
  AS
    l_tab t_split_array;
  BEGIN
    IF TRIM(p_list) IS NOT NULL THEN
      l_tab := split_text(p_list);
      FOR i IN 1 .. l_tab.COUNT LOOP
        UTL_SMTP.rcpt(p_mail_conn, TRIM(l_tab(i)));
      END LOOP;
    END IF;
  END;


BEGIN

  select C_LOGO
    into l_logotipo
    FROM logotipos
   where ID_LOGO=i_tipo_logo
   and rownum <2;

  l_mail_conn := UTL_SMTP.open_connection(i_smtp_host, i_smtp_host);
  UTL_SMTP.helo(l_mail_conn, i_smtp_host);
  UTL_SMTP.mail(l_mail_conn, i_from);

  process_recipients(l_mail_conn, i_to);
  process_recipients(l_mail_conn, i_cc);
  process_recipients(l_mail_conn, i_bcc);

  UTL_SMTP.open_data(l_mail_conn);
  --
  -- header com o TO
  --
  UTL_SMTP.write_data(l_mail_conn, 'To: ' || i_to || UTL_TCP.crlf);
  --
  -- header com o CC
  --
  IF TRIM(i_cc) IS NOT NULL THEN
    UTL_SMTP.write_data(l_mail_conn, 'CC: ' || REPLACE(i_cc, ',', ';') || UTL_TCP.crlf);
  END IF;
  /* PEDRO.C 2021/08/11 comentado por ficar visivel em clientes de email como gmail
  IF TRIM(i_bcc) IS NOT NULL THEN
    UTL_SMTP.write_data(l_mail_conn, 'BCC: ' || REPLACE(i_bcc, ',', ';') || UTL_TCP.crlf);
  END IF;*/
  --
  -- header com o FROM
  --
  UTL_SMTP.WRITE_RAW_DATA( l_mail_conn, UTL_RAW.CAST_TO_RAW('From:'    ||i_nome||'<'|| i_from|| '>' || utl_tcp.CRLF));
  --
  -- header com o SUBJECT
  --
  UTL_SMTP.WRITE_RAW_DATA( l_mail_conn, UTL_RAW.CAST_TO_RAW('Subject:' ||i_subject||utl_tcp.CRLF));
  --
  -- headers com o tipo de conteudo
  --
  UTL_SMTP.write_data(l_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Content-Type: multipart/mixed; boundary="' || l_boundary || '"' || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
  if DBMS_LOB.GETLENGTH(l_logotipo) > 0  then
     UTL_SMTP.write_data(l_mail_conn, 'Content-Type: multipart/related; boundary="' || l_boundary3 || '"' || UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary3 || UTL_TCP.crlf);
  end if;
  UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/html; charset= ISO-8859-1'|| UTL_TCP.crlf);
  --
  -- Corpo do email em html
  --
  IF i_html_msg IS NOT NULL THEN
    UTL_SMTP.write_data(l_mail_conn, 'Content-Transfer-Encoding: quoted-printable'|| UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf);
    UTL_SMTP.WRITE_RAW_DATA(l_mail_conn, UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(i_html_msg)));
    UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
  END IF;
  --
  -- Imagens a incluir no email
  --
  lv_nr_logotipo := 1;
  FOR C1 IN C_LOGOTIPOS LOOP
    IF lv_nr_logotipo = 1 THEN
        lv_ch_logotipo := NULL;
    ELSE
        lv_ch_logotipo := TO_CHAR(lv_nr_logotipo-1);
    END IF;
    IF DBMS_LOB.GETLENGTH( C1.C_LOGO) > 0 THEN
     UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary3 || UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, 'Content-Type: image/png; name="logotipo'||lv_ch_logotipo||'.png"'|| UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, 'Content-Description: logotipo'||lv_ch_logotipo||'.png"' || UTL_TCP.crlf);
     utl_smtp.write_data(l_mail_conn, 'Content-Disposition: inline; <logotipo'||lv_ch_logotipo||'.png>' || UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, 'Content-ID : <logotipo'||lv_ch_logotipo||'.png@domainmail.com>'|| UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, 'Content-Transfer-Encoding: base64'|| UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf);
     UTL_SMTP.WRITE_RAW_DATA(l_mail_conn, UTL_RAW.CAST_TO_RAW(C1.C_LOGO));
     UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary3 || UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf);
    END IF;
    lv_nr_logotipo := lv_nr_logotipo + 1;
  END LOOP;

  UTL_SMTP.close_data(l_mail_conn);
  UTL_SMTP.quit(l_mail_conn);

END;
/
