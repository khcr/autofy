//--
// This file is part of Sonic Pi: http://sonic-pi.net
// Full project source: https://github.com/samaaron/sonic-pi
// License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
//
// Copyright 2013, 2014, 2015, 2016 by Sam Aaron (http://sam.aaron.name).
// All rights reserved.
//
// Permission is granted for use, copying, modification, and
// distribution of modified versions of this work as long as this
// notice is included.
//++

#include <Qsci/qsciscintilla.h>
#include "model/sonicpitheme.h"
#include "osc/oscsender.h"
#include "widgets/sonicpilog.h"
#include <QCheckBox>

class SonicPiLexer;
class QSettings;

class SonicPiScintilla : public QsciScintilla
{
  Q_OBJECT

 public:
  SonicPiScintilla(SonicPiLexer *lexer, SonicPiTheme *theme, QString fileName, OscSender *oscSender, bool autoIndent);

  virtual QStringList apiContext(int pos, int &context_start,
				 int &last_word_start);
  SonicPiTheme *theme;
  QString fileName;
  OscSender *oscSender;
  bool selectionMode;

  void redraw();

  public slots:
    void cutLineFromPoint();
    void tabCompleteifList();
    void transposeChars();
    void setMark();
    void escapeAndCancelSelection();
    void copyClear();
    void hideLineNumbers();
    void showLineNumbers();
    void setLineErrorMarker(int lineNumber);
    void clearLineMarkers();
    void replaceLine(int lineNumber, QString newLine);
    void replaceLines(int lineStart, int lineFinish, QString newLines);
    void forwardLines(int numLines);
    void forwardOneLine();
    void backOneLine();
    void forwardTenLines();
    void backTenLines();
    void moveLineOrSelection(int numLines);
    void moveLineOrSelectionUp();
    void moveLineOrSelectionDown();
    int incLineNumWithinBounds(int linenum, int inc);
    void moveLines(int numLines);
    void deselect();
    void upcaseWordOrSelection();
    void downcaseWordOrSelection();
    void highlightCurrentLine();
    void unhighlightCurrentLine();
    void zoomFontIn();
    void zoomFontOut();
    void newLine();
    void replaceBuffer(QString content, int line, int index, int first_line);
    void newlineAndIndent();
    void completeListOrNewlineAndIndent();

    void sp_paste();
    void sp_cut();

    void showAutoCompletion(bool val);
 private:
    void addKeyBinding(QSettings &qs, int cmd, int key);
    void addOtherKeyBinding(QSettings &qs, int cmd, int key);
    void dragEnterEvent(QDragEnterEvent *pEvent);
    void dropEvent(QDropEvent *pEvent);
    void dragMoveEvent(QDragMoveEvent *event);
    bool event(QEvent *evt);
    bool autoIndent;
    QMutex *mutex;

};
